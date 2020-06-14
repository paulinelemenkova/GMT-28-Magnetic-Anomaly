#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1 from 1 arc minute global data set (here: Ryukyu Trench)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=0.5c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thin,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray
#Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

# Make raster image
# gmt grdimage GEBCO_2019.nc -Cmyocean.cpt -R120/134/-80/-40 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps
grdcut EMAG2_V3_UpCont_DataTiff.tif -R20/120/-65/30 -Gio_mag.tif

#
gdalinfo io_mag.tif -stats
#Minimum=-1461.892, Maximum=2676.992, Mean=0.197, StdDev=60.341
# Step-5. Make color palette
gmt makecpt -Ccyclic -T-1462/2677 > mag.cpt
# makecpt --help

# Step-1. Generate a file
ps=Magnetism_IO.ps
gmt grdimage io_mag.tif -Cmag.cpt -R20/120/-65/30 -JQ5.0i -P -I+a15+ne0.75 -Xc -K > $ps
    
# Add isolines
gmt grdcontour io_sed.nc -R -J -C500 -W0.1p -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    -Bpx204f10a10 -Bpyg20f10a10 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=0.8c \
    -B+t"Sediment thickness of the Indian Ocean" -O -K >> $ps
    
# Step-7. Add legend
gmt psscale -Dg0.0/-65+w12.0c/0.4c+v+o0.3/0i+ml -R20/120/-65/30 -J -Csediments.cpt \
	--FONT_LABEL=7p,Helvetica,dimgray \
	--FONT_ANNOT_PRIMARY=6p,Helvetica,black \
	-Baf+l"Color scale: roma (Perceptually uniform colormap, by F. Crameri [C=RGB])" \
	-I0.2 -By+lm -O -K >> $ps
    
# Step-10. Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=6p,Palatino-Roman,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx0.8c/10.3c+w0.3i+f2+l+o0.15i \
    -Lx11c/-1.3c+c50+w2000k+l"Cylindrical equidist. prj. Scale: km"+f \
    -UBL/-10p/-40p -O -K >> $ps

# Step-11. Add GMT logo
gmt logo -Dx5.2/-2.2+o0.1i/0.1i+w2c -O -K >> $ps

# Step-12. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y6.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
0.7 9.3 GlobSed: Total Sediment Thickness Version 3, 5 arc minute grid
EOF

# Step-13. Convert to image file using GhostScript
gmt psconvert Magnetism_IO.ps -A0.5c -E720 -Tj -Z
# сетка с одинаковыми линиями
#    -Bxg4f2a4 -Byg4f2a4
