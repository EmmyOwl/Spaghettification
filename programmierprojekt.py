#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from julia import Main as jl
jl.include("julia.jl")

from PIL import Image

# picture path
path = "mypic.jpg"

# read picture
im    = Image.open(path)
im    = im.convert('RGBA')
b, h  = im.size
daten = list(im.getdata())

# define parameters
# TODO: Make this a terminal interface or GUI
m      = (0, 0, 0)
r      = 1
dichte = 1

# call julia function returning the RBGA data
Bildebene = jl.snapshot_sphere(b,h,daten,m,r,dichte)

print("Bildebene:", len(Bildebene))
