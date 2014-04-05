from pylab import *
import sys, json

data = json.loads(sys.stdin.read())

subplot(211)
plot(data['epoch'], data['trainperf'], 'r')
plot(data['epoch'], data['t1perf'], 'g')
plot(data['epoch'], data['t2perf'], 'b')
ylabel('percent correct')

subplot(212)
plot(data['epoch'], data['trainerr'], 'r')
plot(data['epoch'], data['t1err'], 'g')
plot(data['epoch'], data['t2err'], 'b')
xlabel('epoch')
ylabel('error')
savefig(sys.argv[1], bbox_inches='tight')
