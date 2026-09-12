# GMT Magnetic Anomaly — Marine Magnetic Anomaly Mapping Scripts

A collection of GMT (Generic Mapping Tools) shell scripts for mapping marine magnetic anomalies over ocean basins and trenches from global magnetic-anomaly grids. Anomaly grids are colour-shaded with a cyclic colour scheme and contoured, with coastal and geographic context. The scripts have been used to generate map figures across the author's marine-geophysical and cartographic publications.

## What the scripts do

Each script builds a complete magnetic-anomaly map, typically chaining:

- grid clipping and subsetting (grdcut) over a study-area bounding box
- colour palette generation (makecpt, cyclic scheme) scaled to the anomaly range
- anomaly grid rendering with illumination (grdimage)
- contours where used (grdcontour)
- coastlines and frames (pscoast)
- colour scale bars in nT (psscale), grids, frames, scale bars and roses (psbasemap)
- annotations and subtitles (pstext), GMT logo (logo)
- export to raster (psconvert) at high resolution

## Data sources

Global marine magnetic-anomaly grids: EMAG2 (Earth Magnetic Anomaly Grid, 2-arc-minute, v3) and WDMAM (World Digital Magnetic Anomaly Map). Coastlines from GSHHG via GMT.

## File naming

Scripts follow GMT-28-magnet-XX.sh, where XX is a feature tag for an ocean basin, trench or region (e.g. IO = Indian Ocean, AS = Arabian Sea, PO = Pacific Ocean, Kerguelen), optionally with the source grid appended (_EMAG2 or _WDMAM).

## Requirements

- GMT 6.x (Generic Mapping Tools): https://www.generic-mapping-tools.org
- A POSIX shell (bash/sh)
- The EMAG2 and/or WDMAM magnetic-anomaly grid(s) available locally
- GDAL (optional) for grid statistics (gdalinfo)

## Usage

Place the required magnetic-anomaly grid in the working directory, adjust the -R region and -J projection at the top of the chosen script, then run:

    bash GMT-28-magnet-JQ-IO.sh

The script writes a PostScript file and converts it to a raster image (JPG/PNG) via psconvert.

## Author and citation

Polina Lemenkova
ORCID: https://orcid.org/0000-0002-5759-1089

These scripts accompany figures in the author's marine-geophysical and cartographic papers; please cite the specific article a given map appears in. The full publication list is available via the ORCID record above.

## License

See the LICENSE file in this repository.
