#!/bin/sh
# Purpose: magnetic anomaly map (here: Kergelen)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

# Step-2. GMT set up
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
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

exec bash

gmt grdcut EMAG2_V2.grd -R50/100/-70/-30 -Gker_mag.nc
gdalinfo ker_mag.nc -stats
# Minimum=-99999.000, Maximum=1763.688, Mean=-4709.593, StdDev=21180.160

# Make color palette
# gmt makecpt -Crainbow.cpt -V -T-500/500 > myocean.cpt
gmt makecpt -Cmag.cpt -V -T-500/500 > myocean.cpt
# gmt makecpt --help

# Generate a file
ps=Magnet_Kgl.ps
gmt grdimage ker_mag.nc -Cmyocean.cpt -R50/100/-70/-30 -JM6.5i -P -I+a15+ne0.75 -Xc -K > $ps

# Add shorelines
# gmt grdcontour ker_mag.nc -R -J -C200 -A1+f10p,25,black -Wthinner,dimgray -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    -Bpxg10f5a5 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=1.5c \
    --MAP_ANNOT_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=11p,0,black \
    --FONT_LABEL=11p,0,black \
    --FONT_TITLE=14p,0,black \
    -B+t"Detailed marine and Earth EMAG-2 airborne Magnetic Anomaly Grid on Kerguelen Plateau" \
    -Lx14.0c/-3.0c+c318/-57+w1000k+l"Mercator projection. Scale (km)"+f \
    -UBL/-5p/-80p -O -K >> $ps

# Texts

# Add legend
gmt psscale -Dg50/-71.5+w16.0c/0.4c+h+ml+e -R -J -Cmyocean.cpt \
    --FONT_LABEL=10p,0,dimgray \
    --FONT_ANNOT_PRIMARY=10p,0,black \
    -Bg100f10a50+l"Color scale: mag (Colors for magnetic anomaly maps), [C=RGB]" \
    -I0.2 -By+l"nT" -O -K >> $ps

# Add GMT logo
gmt logo -Dx6.5/-3.8+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y13.0c -N -O \
    -F+f11p,0,black+jLB >> $ps << EOF
1.2 15.8 EMAG-2 (Earth Magnetic Anomaly Grid, 2 arc min resolution)
EOF

# Convert to image file using GhostScript
gmt psconvert Magnet_Kgl.ps -A1.0c -E720 -Tj -Z
 
