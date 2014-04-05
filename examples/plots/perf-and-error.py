from pylab import *
import sys, json

data = json.loads(sys.stdin.read())

subplot(211)
plot(data['epoch'], data['trainperf'], 'r', label='training')
plot(data['epoch'], data['t1perf'], 'g', label='validation')
plot(data['epoch'], data['t2perf'], 'b', label='test')
ylabel('percent correct')
legend(bbox_to_anchor=(0.0, 1.02, 1.0, 0.102), loc=3,
    ncol=3, mode="expand", borderaxespad=0.0, frameon=False)

subplot(212)
plot(data['epoch'], data['trainerr'], 'r')
plot(data['epoch'], data['t1err'], 'g')
plot(data['epoch'], data['t2err'], 'b')
xlabel('epoch')
ylabel('error')
savefig(sys.argv[1])
