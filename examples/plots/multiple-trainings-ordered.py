from pylab import *
import sys, json, colorsys

def get_color(colors):
  max = 240.0 / 360.0 # From red to blue hue.
  for c in range(colors):
    hue = max * c / colors
    col = [int(x) for x in colorsys.hsv_to_rgb(hue, 1.0, 240)]
    yield "#{0:02x}{1:02x}{2:02x}".format(*col)

data = json.loads(sys.stdin.read())

colors = list(get_color(len(data['perf'])))

subplot(211)
for i, line in enumerate(data['perf']):
  plot(line, color=colors[i])
ylabel('percent correct')
title(data['title'])

subplot(212)
for i, line in enumerate(data['error']):
  plot(line, color=colors[i])
xlabel('epoch')
ylabel('error')

savefig(sys.argv[1])
