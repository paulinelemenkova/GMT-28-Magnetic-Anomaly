#!/bin/sh
# Purpose: magnetic anomaly EMAG2 for Mexico
# GMT modules: gmtset, gmtdefaults, img2grd, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert, pscoast
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/h5/index.html

exec bash

# GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thin,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

#gmt grdcut @earth_wdmam_06m -R14/28/2/11.5 -Gcf_mag_wdmam.nc
gdalinfo cf_mag_wdmam.nc  -stats
# Minimum=-921.700, Maximum=371.300, Mean=-16.655, StdDev=119.717
gmt grdcut @earth_wdmam_03m -R14/28/2/11.5 -Gcf_mag_wdmam.nc
gdalinfo cf_mag_wdmam.nc  -stats
# Minimum=-932.500, Maximum=374.600, Mean=-16.629, StdDev=119.915

# Generate a color palette table from grid
# gmt makecpt --help
#gmt makecpt -Cwysiwyg.cpt -T-921/371 > colors.cpt

#gmt makecpt -C@earth_wdmam.cpt -T-921/371 > colors.cpt
#gmt makecpt -Cjet -T-933/375 > colors.cpt
gmt makecpt -Cmag -T-933/375 > colors.cpt
#gmt makecpt --help

#-Ic Reverse sense of color table spectrum

# Generate a file
ps=Magnet_CF_wdmam.ps

gmt grdimage cf_mag_wdmam.nc -Ccolors.cpt -R14/28/2/11.5 -JM6.5i -P -I+a15+ne0.75 -t30 -Xc -K > $ps

# Add isolines
gmt grdcontour cf_mag_wdmam.nc  -R -J -C50 -Wthinnest,darkbrown -O -K >> $ps

#####################################################################
# CLIPPING
# 1. Start: clip the map by mask to only include country

gmt psclip -R14/28/2/11.5 -JM6.5i CAR.txt -O -K >> $ps

# 2. create map within mask
# Add raster image
gmt grdimage cf_mag_wdmam.nc -Ccolors.cpt -R14/28/2/11.5 -JM6.5i -I+a15+ne0.75 -Xc -P -O -K >> $ps
# Add isolines
gmt grdcontour cf_mag_wdmam.nc -R -J -C100 -A200+f7p,26,darkbrown -Wthinnest,darkbrown -O -K >> $ps
# Add coastlines, borders, rivers
gmt pscoast -R -J \
    -Ia/thinner,blue -Na -N1/thickest,tomato -W0.1p -Df -O -K >> $ps

# 3: Undo the clipping
gmt psclip -C -O -K >> $ps
#####################################################################

# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpx2f1a1 -Bpyg4f1a1 -Bsxg4 -Bsyg2 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=9p,25,black \
    --FONT_TITLE=13p,25,black \
    -B+t"WDMAM (World Digital Magnetic Anomaly Map) for CAR" -O -K >> $ps
    
# Add legend
gmt psscale -Dg14/1.0+w16.5c/0.4c+h+o0.0/0i+ml+e -R -J -Ccolors.cpt \
    --FONT_LABEL=9p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=8p,25,black \
    -Bg100f20a100+l"Color scale 'mag' GMT cpt for magnetic anomaly maps [C=RGB, -T-933/375], nanoTesla" \
    -I0.2 -By+l"nT" -O -K >> $ps

# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=9p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.8c/-2.3c+c50+w250k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-70p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P -Ia/thinnest,blue -Na -N1/thick,white -Wthin,darkslategray -Df -O -K >> $ps

# Texts

# Add GMT logo
gmt logo -Dx7.3/-3.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.0c -Y0.9c -N -O \
    -F+f10p,25,black+jLB >> $ps << EOF
3.5 16.6 Grid resolution: 3-arc-minutes (7200 x 3600 dimensions)
EOF

# Convert to image file using GhostScript
gmt psconvert Magnet_CF_wdmam.ps -A0.5c -E720 -Tj -Z
