/*
 ******************************************************************
 * HISTORY
 * 15-Oct-94  Jeff Shufelt (js), Carnegie Mellon University
 *      Prepared for 15-681, Fall 1994.
 *
 ******************************************************************
 */

#include <stdio.h>
#include <pgmimage.h>
#include <backprop.h>

extern void exit();

load_target(img, net)
IMAGE *img;
BPNN *net;
{
  /*** Target units start at index 1. ***/
  net->target[1] = img->target;
}


/***********************************************************************/
/********* You shouldn't need to change any of the code below.   *******/
/***********************************************************************/

load_input_with_image(img, net)
IMAGE *img;
BPNN *net;
{
  double *units;
  int nr, nc, imgsize, i, j, k;

  nr = ROWS(img);
  nc = COLS(img);
  imgsize = nr * nc;;
  if (imgsize != net->input_n) {
    printf("LOAD_INPUT_WITH_IMAGE: This image has %d pixels,\n", imgsize);
    printf("   but your net has %d input units.  I give up.\n", net->input_n);
    exit (-1);
  }

  units = net->input_units;
  k = 1;
  for (i = 0; i < nr; i++) {
    for (j = 0; j < nc; j++) {
      units[k] = ((double) img_getpixel(img, i, j)) / 255.0;
      k++;
    }
  }
}
