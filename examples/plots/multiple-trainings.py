from pylab import *
import sys, json

data = json.loads(sys.stdin.read())

subplot(211)
for line in data['perf']:
  plot(line, 'g', alpha=0.4)
ylabel('percent correct')

subplot(212)
for line in data['error']:
  plot(line, 'r', alpha=0.4)
xlabel('epoch')
ylabel('error')
savefig(sys.argv[1], bbox_inches='tight')
