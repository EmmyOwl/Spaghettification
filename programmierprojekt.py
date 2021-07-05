#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from julia import Main as jl
jl.include("julia.jl")

from PIL import Image

# picture path
path = input("Input picture path.\n")

# read picture
im    = Image.open(path)
im    = im.convert('RGBA')
b, h  = im.size
daten = list(im.getdata())

# define parameters
m      = input("\nInput sphere center as comma-seperated values x,y,z.\n")
m      = tuple([float(s) for s in m.split(',')])
r      = float(input("\nInput value for r.\n"))
dichte = float(input("\nInput value for dichte.\n"))

# call julia function returning the RGBA data
Bildebene = jl.snapshot_sphere(b, h, daten, m, r, dichte)

# flatten the array and convert to integers
print(type(Bildebene), len(Bildebene[250]), len(Bildebene))
Bildebene2 = []
for i in Bildebene:
    Bildebene2 += i

Bildebene = Bildebene2
Bildebene = [tuple([int(v) for v in p]) for p in Bildebene]

# create new image from mapped image data and save as png
newim = Image.new(mode="RGBA", size=(500, 500))
newim.putdata(Bildebene)
newim.show()
newim.save("newim.png")

print("\nCreated file newim.png by projecting input picture", \
      path, "onto a sphere with parameters\n"\
        "m      =", m, \
      "\nr      =", r, \
      "\ndichte =", dichte)
