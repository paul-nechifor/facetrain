/*
 ******************************************************************
 * HISTORY
 * 15-Oct-94  Jeff Shufelt (js), Carnegie Mellon University
 *      Prepared for 15-681, Fall 1994.
 *
 * Tue Oct  7 08:12:06 EDT 1997, bthom, added a few comments,
 *       tagged w/bthom
 *
 ******************************************************************
 */

#include <stdio.h>
#include <math.h>
#include <pgmimage.h>
#include <backprop.h>

extern char *strcpy();
extern void exit();

int evaluate_single_performance(BPNN *net, double *err);
int evaluate_on_performance(BPNN *net, double *err);

main(argc, argv)
int argc;
char *argv[];
{
  char netname[256], trainname[256], test1name[256], test2name[256];
  IMAGELIST *trainlist, *test1list, *test2list;
  int ind, epochs, seed, savedelta, interrupt, nHidden, nOutput;

  seed = 102194;   /*** today's date seemed like a good default ***/
  epochs = 100;
  savedelta = 100;
  netname[0] = trainname[0] = test1name[0] = test2name[0] = '\0';
  interrupt = 0;
  nHidden = 4;
  nOutput = 1;
  int classify = 0;
  int (*eval_func)(BPNN *net, double *err) = NULL;

  if (argc < 2) {
    printusage(argv[0]);
    exit (-1);
  }

  /*** Create imagelists ***/
  trainlist = imgl_alloc();
  test1list = imgl_alloc();
  test2list = imgl_alloc();

  /*** Scan command line ***/
  for (ind = 1; ind < argc; ind++) {

    /*** Parse switches ***/
    if (argv[ind][0] == '-') {
      switch (argv[ind][1]) {
        case 'n': strcpy(netname, argv[++ind]);
                  break;
        case 'e': epochs = atoi(argv[++ind]);
                  break;
        case 's': seed = atoi(argv[++ind]);
                  break;
        case 'S': savedelta = atoi(argv[++ind]);
                  break;
        case 't': strcpy(trainname, argv[++ind]);
                  break;
        case '1': strcpy(test1name, argv[++ind]);
                  break;
        case '2': strcpy(test2name, argv[++ind]);
                  break;
        case 'i': savedelta = 1;
            interrupt = 1;
                  break;
        case 'H': nHidden = atoi(argv[++ind]);
                  break;
        case 'o': nOutput = atoi(argv[++ind]);
                  break;
        case 'c': classify = 1;
        default : printf("Unknown switch '%c'\n", argv[ind][1]);
                  break;
      }
    }
  }

  /*** If any train, test1, or test2 sets have been specified, then
       load them in. ***/
  if (trainname[0] != '\0')
    imgl_load_images_from_textfile(trainlist, trainname);
  if (test1name[0] != '\0')
    imgl_load_images_from_textfile(test1list, test1name);
  if (test2name[0] != '\0')
    imgl_load_images_from_textfile(test2list, test2name);

  /*** If we haven't specified a network save file, we should... ***/
  if (netname[0] == '\0') {
    printf("%s: Must specify an output file, i.e., -n <network file>\n",
     argv[0]);
    exit (-1);
  }

  /*** Don't try to train if there's no training data ***/
  if (trainname[0] == '\0') {
    epochs = 0;
  }

  /*** Initialize the neural net package ***/
  bpnn_initialize(seed);

  /*** Show number of images in train, test1, test2 ***/
  printf("%d images in training set\n", trainlist->n);
  printf("%d images in test1 set\n", test1list->n);
  printf("%d images in test2 set\n", test2list->n);

  /*** If we've got at least one image to train on, go train the net ***/
  backprop_face(trainlist, test1list, test2list, epochs, savedelta, netname,
		  interrupt, nHidden, nOutput, eval_func, classify);

  exit(0);
}

backprop_face(trainlist, test1list, test2list, epochs, savedelta, netname,
	  interrupt, nHidden, nOutput, eval_func, classify)
IMAGELIST *trainlist, *test1list, *test2list;
int epochs, savedelta, interrupt, nHidden, nOutput, classify;
char *netname;
int (*eval_func)(BPNN *net, double *err);
{
  IMAGE *iimg;
  BPNN *net;
  int train_n, epoch, i, imgsize;
  double out_err, hid_err, sumerr;

  train_n = trainlist->n;

  /*** Read network in if it exists, otherwise make one from scratch ***/
  if ((net = bpnn_read(netname)) == NULL) {
    if (train_n > 0) {
      printf("Creating new network '%s'\n", netname);
      iimg = trainlist->list[0];
      imgsize = ROWS(iimg) * COLS(iimg);
      net = bpnn_create(imgsize, nHidden, nOutput);
    } else {
      printf("Need some images to train on, use -t\n");
      return;
    }
  }

  // If no evaluation function is chosen, pick an appropriate one.
  if (eval_func == NULL) {
    if (net->output_n == 1) {
      eval_func = evaluate_single_performance;
    } else {
      eval_func = evaluate_on_performance;
    }
  }

  if (classify) {
    print_classification(net, trainlist, eval_func);
    exit(0);
  }

  if (epochs > 0) {
    printf("Training underway (going to %d epochs)\n", epochs);
    printf("Will save network every %d epochs\n", savedelta);
    fflush(stdout);
  }

  /*** Print out performance before any epochs have been completed. ***/
  printf("performance>>> 0 0.0 ");
  performance_on_imagelist(net, trainlist, eval_func);
  performance_on_imagelist(net, test1list, eval_func);
  performance_on_imagelist(net, test2list, eval_func);
  printf("\n");
  fflush(stdout);

  /************** Train it *****************************/
  for (epoch = 1; epoch <= epochs; epoch++) {

    printf("performance>>> %d ", epoch);  fflush(stdout);

    sumerr = 0.0;
    for (i = 0; i < train_n; i++) {

      /** Set up input units on net with image i **/
      load_input_with_image(trainlist->list[i], net);

      /** Set up target vector for image i **/
      load_target(trainlist->list[i], net);

      /** Run backprop, learning rate 0.3, momentum 0.3 **/
      bpnn_train(net, 0.3, 0.3, &out_err, &hid_err);

      sumerr += (out_err + hid_err);
    }
    printf("%g ", sumerr);

    /*** Evaluate performance on train, test, test2, and print perf ***/
    performance_on_imagelist(net, trainlist, eval_func);
    performance_on_imagelist(net, test1list, eval_func);
    performance_on_imagelist(net, test2list, eval_func);
    printf("\n");  fflush(stdout);

    /*** Save network every 'savedelta' epochs ***/
    if (!(epoch % savedelta)) {
      bpnn_save(net, netname);
    }

    if (interrupt) {
      printf("interrupt>>>%d\n", epoch);
      fflush(stdout);
      // Block until the listener is ready.
      getchar();
    }

  }
  printf("\n"); fflush(stdout);

  /** Save the trained network **/
  if (epochs > 0) {
    bpnn_save(net, netname);
  }
}

/*** Computes the performance of a net on the images in the imagelist. ***/
/*** Prints out the percentage correct on the image set, and the
     average error between the target and the output units for the set. ***/
performance_on_imagelist(net, il, eval_func)
BPNN *net;
IMAGELIST *il;
int (*eval_func)(BPNN *net, double *err);
{
  double err, val;
  int i, n, j, correct;

  err = 0.0;
  correct = 0;
  n = il->n;

  if (n == 0) {
    return;
  }

  for (i = 0; i < n; i++) {
    /*** Load the image into the input layer. **/
    load_input_with_image(il->list[i], net);
    /*** Run the net on this input. **/
    bpnn_feedforward(net);
    /*** Set up the target vector for this image. **/
    load_target(il->list[i], net);
    /*** See if it got it right. ***/
    if (eval_func(net, &val)) {
      correct++;
    }
    err += val;
  }

  err = err / (double) n;

  printf("%g %g ", ((double) correct / (double) n) * 100.0, err);
}

void print_classification(BPNN *net, IMAGELIST *il,
    int (*eval_func)(BPNN *net, double *err)) {
  int i, j, is_correct;
  double err;

  for (i = 0; i < il->n; i++) {
    load_input_with_image(il->list[i], net);
    bpnn_feedforward(net);
    load_target(il->list[i], net);

    is_correct = eval_func(net, &err);
    printf("imgclassif>>>%d %d %lf", i, is_correct, err);

    for (j = 1; j <= net->output_n; j++) {
      printf(" %lf", net->output_units[j]);
    }
    printf("\n");
    fflush(stdout);
  }
}

int evaluate_single_performance(BPNN *net, double *err) {
  double delta = net->target[1] - net->output_units[1];
  *err = (0.5 * delta * delta);

  int target_is_on = net->target[1] > 0.5;
  int output_is_on = net->output_units[1] > 0.5;
  return target_is_on == output_is_on;
}

// Under this evaluation scheme, only one target must be set to the maximum and
// the classification is correct if that output unit is the maximum.
int evaluate_on_performance(BPNN *net, double *err) {
  int n = net->output_n;
  int max_target = get_max_unit(net->target, n);
  int max_output = get_max_unit(net->output_units, n);
  double delta = net->target[max_target] - net->output_units[max_target]; // sic
  *err = (0.5 * delta * delta);
  return max_target == max_output;
}

int get_max_unit(double *array, int n) {
  int i, max_unit = 1;
  double max = array[max_unit];
  for (i = max_unit + 1; i <= n; i++) {
    if (array[i] > max) {
      max = array[i];
      max_unit = i;
    }
  }
  return max_unit;
}

printusage(prog)
char *prog;
{
  printf("USAGE: %s\n", prog);
  printf("       -n <network file>\n");
  printf("       [-e <number of epochs>]\n");
  printf("       [-s <random number generator seed>]\n");
  printf("       [-S <number of epochs between saves of network>]\n");
  printf("       [-t <training set list>]\n");
  printf("       [-1 <testing set 1 list>]\n");
  printf("       [-2 <testing set 2 list>]\n");
  printf("       [-T]\n");
}
