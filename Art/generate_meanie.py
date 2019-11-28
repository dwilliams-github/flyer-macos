from xml.etree import ElementTree as et
import math

#
# Sketch supports pasting SVG...
# Here is an opportunity to generate a perfectly animated spinning "meanie"
#

def make_one(theta):
    doc = et.Element('svg', width='64', height='64', version='1.1', xmlns='http://www.w3.org/2000/svg')
    et.SubElement(doc, 'circle', cx='32', cy='32', r='20', fill='none', stroke='blue', style="stroke-width:4")
    
    cost = math.cos(theta)
    
    x1 = 27*cost + 1
    x2 = 14*cost - 1
    y = 24
    
    et.SubElement(doc, 'line',
        x1=str(32-x1), x2=str(32-x2),
        y1=str(32+y), y2=str(32+y),
        stroke='blue', style="stroke-width:3"
    )

    et.SubElement(doc, 'line',
        x1=str(32-x1), x2=str(32-x2),
        y1=str(32-y), y2=str(32-y),
        stroke='blue', style="stroke-width:3"
    )

    et.SubElement(doc, 'line',
        x1=str(32+x1), x2=str(32+x2),
        y1=str(32+y), y2=str(32+y),
        stroke='blue', style="stroke-width:3"
    )

    et.SubElement(doc, 'line',
        x1=str(32+x1), x2=str(32+x2),
        y1=str(32-y), y2=str(32-y),
        stroke='blue', style="stroke-width:3"
    )

    if theta > 0:
        width = 20*cost
        if abs(width) < 0.001:
            path = 'M32,12 32,52'
        else:
            path = 'M32,12 a{:f},20 0 1,{} 0,40'.format(math.fabs(width),1 if width < 0 else 0)

        et.SubElement(doc, 'path', d=path, stroke='blue', fill="none", style="stroke-width:4")

    return doc


for i in range(0,16):
    theta = math.pi*i/16.0
    print("--- {} ---".format(i))
    print(et.tostring(make_one(theta)).decode())
