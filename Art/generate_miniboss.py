from xml.etree import ElementTree as et
import math

#
# Use the technique used for the meanie animation to generate the
# spinning lights on the mini boss
#
# We don't bother generating the entire image. The cut and paste will
# add the lights to anything existing.
#

def make_one(i, n, num):
    doc = et.Element('svg', width='64', height='64', \
        version='1.1', xmlns='http://www.w3.org/2000/svg')

    et.SubElement(doc, 'rect', x="0", y="0", width="64", height="64", fill="none")


    step = math.pi / num
    dframe = step * i / n
    
    for j in range(num):
        theta0 = step*j + dframe
        theta1 = min(math.pi,theta0 + step/2)

        t0 = 32-28*math.cos(theta0)
        t1 = 32-28*math.cos(theta1)
        
        if t1 > t0:
            et.SubElement(doc, 'rect',
                x = str(t0),
                y = str(32-5),
                width = str(t1-t0),
                height = "10",
                fill="#FF8585"
            )

    return doc


for i in range(0,8):
    print("--- {} ---".format(i))
    print(et.tostring(make_one(i,8,3)).decode())
