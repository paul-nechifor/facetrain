from pylab import *
import sys, json

data = json.loads(sys.stdin.read())

val = data['output']
pos = arange(4)+.5

fig = figure(1, figsize=(3, 2))
barh(pos,val, align='center',height=0.4)
yticks(pos, ('up', 'right', 'straight', 'left'))
xticks((0.0, 1.0))
savefig(sys.argv[1], bbox_inches='tight', dpi=100)
