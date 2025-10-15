#!/bin/csh -x
#Taiwan GPS and seismicityCSV
#4 change legend

# To add in:
# auto BATS-focal mechanisms: https://tecws1.earth.sinica.edu.tw/AutoBATS/
#problem to be solved: font color of scales
# to do: FMs' shear sense and size Mw
# FM only for half year

gmt set TICK_LENGTH 									 = 0.2c
gmt set MAP_FRAME_AXES                 = WESNZ
gmt set MAP_FRAME_PEN                  = thicker,black
gmt set MAP_FRAME_TYPE                 = fancy+ #plain
gmt set MAP_DEGREE_SYMBOL							 = degree
gmt set MAP_FRAME_WIDTH                = 3p
gmt set MAP_ANNOT_MIN_ANGLE            = 20
## FONT Parameters
gmt set FONT_ANNOT_PRIMARY             = 14p,0,black
gmt set FONT_ANNOT_SECONDARY           = 12p,P0,black
gmt set FONT_HEADING                   = 20p,1,black
gmt set FONT_LOGO                      = 8p,0,black
gmt set FONT_TAG                       = 20p,0,black
gmt set FONT_TITLE                     = 20p,1,black
gmt set MAP_TITLE_OFFSET 							 = 0.8c
## For setting scale
gmt set FONT_LABEL                     = 12p,0,black
gmt set MAP_SCALE_HEIGHT							 = 8p
gmt set MAP_TICK_PEN_PRIMARY					 = thinner,black
gmt set MAP_DEFAULT_PEN								 = thinner,black
gmt set PS_MEDIA=A4 PS_CONVERT="" MAP_ORIGIN_X=3c MAP_ORIGIN_Y=13c PS_PAGE_ORIENTATION=portrait
gmt set FORMAT_GEO_MAP=ddd.xG #ddd:mm:ssG
#gmt default -D
#gmt defaults -D > ~/gmt.conf
## Declare files and directories   #variables= (note: no space left...)
DATAdir=~/Documents/GMT/DATA
DATAdir1=/Users/wanlin/Documents/05.Taiwan/00.data/00.GMT/Taiwan_structure
DATAdir2=/Users/wanlin/Documents/05.Taiwan/00.data/03.seismicity
outputfiledir=./outputPDF
## plot background seismicity
seismicityCSV=./data/Wu_relocate_selected.dat
clusteredSeismicity=$DATAdir2/2006_HC_clustered_GDMS.txt
autoBATS=$DATAdir2/2006_half_year_psmeca.txt
autoBATS_full=$DATAdir2/2006_half_year_fullmoment.txt

Bathymetry=../00.data/DEM/GEBCO_2021.nc
faultfile=../00.data/00.GIS_shp/ActiveFaults_CGS2010_WGS84.txt
shoreline=../00.data/00.GIS_shp/Tw_shoreline.txt
CGPSfile=/Users/wanlin/Documents/05.Taiwan/00.data/01.GPS/CGPS.dat
																	 # https://earthquake.usgs.gov
seis_dot_size=0.1 # basis size
seis_bound=0.001p

## Declare region parameters
west=120
east=121.2
south=21.5
north=22.5


##for profile
profile_W=120.0
profile_E=121.0
profile_N=21.9
profile_S=21.9

#314.5 km

start=$profile_W/$profile_N
end=$profile_E/$profile_S
proj_profile_km=103.2

proj=M15c # Mercator projection with plot width 15 cm
insetsize=6c #width inset size, change according to proj size
range="${west}/${east}/${south}/${north}"
borderx=a0.5f0.2g1    #a: annotation, f: font, g: grid (will be covered by image), lable, a10f5g10
bordery=a0.5f0.2g1
bordershow=WNes
title="  "

insetcentre=120/22/? #inset center; size is ?, decided by insetsize
insetrange=118.447/122.4/18.0/23.6
grd2=cut.nc
#gmt grdcut @earth_relief_03s -G$grd2 -R$range


gmt begin ${outputfiledir}/source_area_plots_autoBATS  pdf A+m0.5c #eps,PNG

	echo "*****************plot basemap*****************"
	gmt basemap -J${proj} -R${range} -Bx${borderx}+l"Lon." -By${bordery}+l"Lat." -B${bordershow}+t"${title}"

	##gmt makecpt -Cgeo -T-6000/4000 -Z -V >topotw.cpt
	##gmt makecpt -Cgeo -T-6000/4000 -Z -V >topotw.cpt
	gmt grdimage -J${proj} -R${range} $grd2  -Cgray.cpt -I+d -V # ../00.data/DEM/GEBCO_2021.nc ../00.data/DEM/GEBCO_2021.nc
  gmt psxy  ./data/land_polygons_osm_planet.gmt -J${proj} -R${range} -Wthinnest,black -Ggrey

	echo "***************** plot seismicity*****************"
	awk '{print $4, $3, $5, $6}' ${seismicityCSV} > siesmictemp1
		# Reformat the original csv file is directly from USGS;
		# CSV: -F"," { x-lon,  y-lat, color-depth, size-mag}
	echo 'makecpt once'
	#gmt makecpt -Cseis -T0/200/1 -A40 -Z -V -Ic > seiscolor.cpt

echo "plot index line"
echo $profile_W  $profile_N  > L_index_0.gmt
echo $profile_E  $profile_S >> L_index_0.gmt


gmt plot L_index_0.gmt -J${proj} -R${range} -Sf-2/1c -I1  -W3p,red
gmt plot L_index_0.gmt -J${proj} -R${range} -Sf-2/1c -I1  -W1p,white





	echo "***************** plot AutoBATS focal mechanism *****************"

	#awk '{print $1, $2, $3, $4, $5, $6, $7}'  $autoBATS >BATS_temp
	#gmt meca BATS_temp -h12  -J${proj} -R${range} -Gyellow@40  -Sa0.6c -t20  -V  #-Cseiscolor.cpt -Ggrey@30 not sure why?Representation of pen width (seiscolor.cpt) not recognized
	#autoBATS file format:Longitude, Latitude, Centroid Depth, strike2, dip2, slip2, Mw, Longitude, Latitude, Label
	#note that the label would affect the plotting transparency

	# Full moment tensor
	#awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10}'  $autoBATS_full >autoBATS_temp
	#gmt meca autoBATS_temp -h12  -J${proj} -R${range} -Gyellow@40  -Sm0.6c  -V -t40
	#gmt meca autoBATS_temp -h12  -J${proj} -R${range}  -Gyellow@20  -Sm0.6c  -V -t40 #plot 2 nodal planes: -T0
	#Longitude, Latitude, Centroid Depth, Mrr, Mtt, Mff, Mrt, Mrf, Mtf, exponent, Longitude, Latitude, Label

	echo "***************** plot focal mechanism *****************"
	# usage:https://docs.generic-mapping-tools.org/6.2/supplements/seis/psmeca.html?highlight=psmeca
	#gmt makecpt -Cseis -T0/600/5 -Z -V -Ic > CGMT_seis.cpt

	#awk '{print $1,$2,$3,$4,$5,$7,$8,$9,$10,0,0,0}' GCMT_catlog.gmt > temp
	#X  Y  depth  strike  dip  rake  mag  [newX  newY]  [title]

#cat << E > meca.txt
#120.494 21.754 50.9 165 30 -76 7.0
#120.410 21.995 47.03 151 48 0 6.9
#E
#gmt meca meca.txt  -J${proj} -R${range}  -Gred@20 -t30 -Sa0.6c -V   #-Cseiscolor.cpt not sure why?Representation of pen width (seiscolor.cpt) not recognized

# Full moment tensor
cat << E > meca.txt
120.5553 21.6873 40 -3.249847 0.719068 2.530779 1.305014 0.252347 -1.609100 26
120.4196 21.9698 54 -2.084872 2.392639 -0.307766 0.401382 0.012981 -0.339460 26
E
cat << E > GCMTmeca.txt
120.52 21.81 20 -3.16 0.42 2.74 1.23 -1.55 -1.23 26 120.4 21.81 GCMT1226
120.40 22.02 33 -0.38 2.21 -1.83 2.11 0.14 -0.81 26 120.4 22.02 GCMT1234
E
#gmt meca meca.txt  -J${proj} -R${range}  -Gdarkred@20  -Sm0.6c  -V -t40 #plot two nodal planes:-T0

#classify by another file: focal_type.sh
echo "plot meca from classification by focal_type.sh"
gmt meca n_temp_bats -Gblue@20  -J${proj} -R${range} -Sm0.5c+f0p,1,red
gmt meca r_temp_bats -Gred@20  -J${proj} -R${range} -Sm0.5c+f0p,1,red
gmt meca ss_temp_bats -Ggreen@20  -J${proj} -R${range} -Sm0.5c+f0p,1,red
gmt meca ssr_temp_bats -Ggreen@60  -J${proj} -R${range} -Sm0.5c+f0p,1,red
gmt meca ssn_temp_bats -Ggreen@60 -J${proj} -R${range} -Sm0.5c+f0p,1,red
gmt meca rss_temp_bats -Gred@50  -J${proj} -R${range} -Sm0.5c+f0p,1,red
gmt meca nss_temp_bats -Gblue@50  -J${proj} -R${range} -Sm0.5c+f0p,1,red
echo " # legend focal classifications # "

echo 121.08 22.4  10 90 75  0 7  | gmt meca  -Ggreen@20  -J${proj} -R${range} -Sa0.5c+f0p -N -V
echo 121.15 22.4 Strike-slip | gmt text -F+f10p,Helvetica,green=0.2p,black,solid+jCT -N -V

echo 121.08 22.35 10 90 45 -90 7  | gmt meca  -Gblue@20  -J${proj} -R${range} -Sa0.5c+f0p -N -V
echo 121.15 22.35 Normal | gmt text -F+f10p,Helvetica,blue=0.2p,black,solid+jCT -N -V

echo 121.08 22.3  10 220 45 90 7  | gmt meca  -Gred@20  -J${proj} -R${range} -Sa0.5c+f0p -N -V
echo 121.15 22.3 Reverse | gmt text -F+f10p,Helvetica,red=0.2p,black,solid+jCT -N -V

# PROJECTION #
#### plot profile lines
## Accessory :north indication (-TdjTL) and scale (-Lx...)20p,1,white=1p,black,solid
echo "*****************Plot  Accessory *****************"
	gmt basemap -TdjTL+o0.6c/1.5c+w1.5c+l,,,N+f  -Lx7.5c/1c+c22+w20k+f1+u --MAP_TITLE_OFFSET=0.2c  --FONT_TITLE=15p,31,black  --FONT_ANNOT_PRIMARY=12p,1,black=0.3p,white,solid -V   #--FONT_LABEL=12p,31,white=0.3p,black,solid #-Lg110/-15+c0+w1000k+l+f2 -V
																								# -C*.cpt+Uunit (change unit from meter to??)
echo "*****************plot inset*****************"
gmt inset begin -DjLB+o-0.9c/0.1c+w$insetsize -N #-DjLB+w$insetsize  # offset +o0.1c/0.1c
		gmt set MAP_FRAME_TYPE                 = inside
		#gmt set MAP_FRAME_PEN = th, black
		gmt set FONT_ANNOT_PRIMARY             = 6p,Palatino-Roman,black
		gmt set FONT_ANNOT_SECONDARY           = 6p,Palatino-Roman,black
		#gmt FONT_ANNOT=6p,29,black
								# position (bottom left); w size o offset
		#-D$coastResolution (full,high,intermediate,low,crude, or a-automatic) -G$landColor -B$bordershow -N 1=national broader -W coasteline color
		gmt coast -R$insetrange -Ba2f1 -BNEws -W0.2p -Df -JM? -N1/0.1p  -Gwhite -Slightblue@20 -Cblue@5 -A1000

		echo "~~~~~Inset plot structure line"
		dir=/Users/wanlin/Documents/11._TEMP/gmtManila
		gmt plot ${dir}/Manila_data/oc_boundary.gmt -W2p,darkblue,dotted
	  # -Sf[±]gap[/size][+l|+r][+b|c|f|s[angle]|t|v][+ooffset][+p[pen]].
	  gmt plot ${dir}/Manila_data/Manilatrench.gmt -W2p,black -Gblack -Sf1.5c/0.08i+l+t+p0.01i
	  gmt plot ${dir}/Manila_data/eastLuzone_pholpTrench.gmt -W2p,black -Gblack -Sf1.5c/0.08i+l+t+p0.01i
	# philipine faults
	  gmt psxy Manila_data/phili_n2.gmt  -W0.8p,black


		cat Manila_GCMT| awk '{if ($15== '1'){printf "%s\n",$line}}'| gmt meca  -Gred@20  -R$insetrange -JM? -Sm0.2c+f0p
		cat Manila_GCMT| awk '{if ($15== '2'){printf "%s\n",$line}}'| gmt meca  -Gblue@20  -R$insetrange -JM? -Sm0.2c+f0p
		cat Manila_GCMT| awk '{if ($15== '3'){printf "%s\n",$line}}'| gmt meca  -Ggreen@20  -R$insetrange -JM? -Sm0.2c+f0p


		######### TEXT NOTEs
		txt_font=12p,1,black #=0.1p,white
		txt_note_shift=0.05c/0.1c
		txt_loc=B #TCB
		color_lb=0.3p,black@50,solid
		color_lb_fill=white@10
		conor=10%/10%
		echo "GCMT"  | gmt text  -F+f${txt_font}+c${txt_loc}L -Dj${txt_note_shift} -W${color_lb} -G${color_lb_fill} -C$conor -V
		######################33

		# Plot a rectangle region using -Sr+s
		echo $east $north >box.xy
		echo $east $south >>box.xy
		echo $west $south >>box.xy
		echo $west $north >>box.xy
		echo $east $north >>box.xy
		gmt psxy box.xy -R$insetrange -JM? -W1p,255/0/0 -Am -V
gmt inset end

echo "*****************plot inset ENDDDDD *****************"


#echo "#### plot PROJECTIONS ###"

#awk '{print $4, $3, $5, $6}' ${seismicityCSV}| gmt project -C118.276/21.943 -A330 -W-.2/.2 -L0/10 -H1 > projection.dat

# gmt project -C120/25 -A45 -L0/123 -G123 -Q | tail -1
# -C = defines the center of your transect
# -A = azimuth of transect (CW from N)
# -W = Width of the transect in degrees
# -L = length of transect in degrees
# -H = Header declaration
# projection.dat = new file with the original data and the projected locations


echo"#################subplot set#################"


jx=5c #height of seisplot
			# remeber to modify the -Y below

echo "# Fig (C) background seismicity # "

awk '{if (NR > 1) print $1, $2, $3, $4}'  siesmictemp1  > siesmictemp2
gmt coupe siesmictemp2 -Y-6.7c  -R-1/${proj_profile_km}/0/100 -JX15c/-${jx}c  -Fsc0.04c/0 -Aa${start}/${end}/90/50/0/200  -V
#-Aalon1/lat1/lon2/lat2/dip/p_width/dmin/dmax[+f]
#gmt coupe siesmictemp_cl -R0/300/-100/0 -JX15c/5c -Bxa100  -BWStr  -W0.5 -Gred -Ered  -Fsc0.04c/0 -Aa${start}/${end}/90/20/0/200  -V
#X  Y  depth  strike  dip  rake  mag  [newX  newY]  [title]

echo "plot profile of focal mechanisms"
#gmt coupe BATS_temp -h12 -Sa0.6c -R0/${proj_profile_km}/0/100  -JX15c/-${jx} -Gyellow@40 -t20 -W0.1p -N -Aa${start}/${end}/90/20/0/200  -V
#full moment tensor
#gmt coupe autoBATS_temp -h12 -Sm0.6c -R0/${proj_profile_km}/0/100  -JX15c/-${jx} -Gyellow@30 -W0.1p -t10 -Q  -Aa${start}/${end}/90/50/0/200  -V
#autoBATS file format:Longitude, Latitude, Centroid Depth, strike2, dip2, slip2, Mw, Longitude, Latitude, Label

echo "plot profile of focal mechanisms of two main shocks"
# two main shocks
#awk '{print $1, $2, $3, $4, $5, $6, $7}'  meca.txt >temp
#gmt coupe temp -Sa0.6c -R0/${proj_profile_km}/0/100  -JX15c/-${jx} -W0.1p -Gred@40 -t20 -N -Aa${start}/${end}/90/20/0/200  -V
#

#blue=Normal; green=strike-slip; red=thrust
gmt coupe n_temp_bats -Sm0.5c+f0p -R0/${proj_profile_km}/0/100  -JX15c/-${jx} -Gblue@30 -W0.05p -t10 -Q  -Aa${start}/${end}/90/35/0/200  -V
gmt coupe r_temp_bats -Sm0.5c+f0p -R0/${proj_profile_km}/0/100  -JX15c/-${jx} -Gred@30 -W0.05p -t10 -Q  -Aa${start}/${end}/90/35/0/200  -V
gmt coupe ss_temp_bats -Sm0.5c+f0p -R0/${proj_profile_km}/0/100  -JX15c/-${jx} -Ggreen@30 -W0.05p -t10 -Q  -Aa${start}/${end}/90/35/0/200  -V
#gmt coupe nss_temp_bats -Sm0.5c+f0p -R0/${proj_profile_km}/0/100  -JX15c/-${jx} -Gblue@50 -W0.05p -t10 -Q  -Aa${start}/${end}/90/35/0/200  -V
#gmt coupe rss_temp_bats -Sm0.5c+f0p -R0/${proj_profile_km}/0/100  -JX15c/-${jx} -Gred@50 -W0.05p -t10 -Q  -Aa${start}/${end}/90/35/0/200  -V
#gmt coupe ssn_temp_bats -Sm0.5c+f0p -R0/${proj_profile_km}/0/100  -JX15c/-${jx} -Ggreen@50 -W0.05p -t10 -Q  -Aa${start}/${end}/90/35/0/200  -V
#gmt coupe ssr_temp_bats -Sm0.5c+f0p -R0/${proj_profile_km}/0/100  -JX15c/-${jx} -Ggreen@50 -W0.05p -t10 -Q  -Aa${start}/${end}/90/35/0/200  -V



##
#gmt coupe meca.txt -Sm0.6c -R0/${proj_profile_km}/0/100  -JX15c/-${jx} -Gblack@10 -W0.1p -t10 -Q  -Aa${start}/${end}/90/50/0/200  -V


######### TEXT NOTEs
txt_font=12p,1,black #=0.1p,white
txt_note_shift=0.05c/0.1c
txt_loc=B #TCB
color_lb=0.3p,black@50,solid
color_lb_fill=white@10
conor=10%/10%
echo "AutoBATS"  | gmt text  -F+f${txt_font}+c${txt_loc}L -Dj${txt_note_shift} -W${color_lb} -G${color_lb_fill} -C$conor -V


#####
gmt basemap  -R0/${proj_profile_km}/0/60 -JX15c/-${jx}  -Bxa50f10+l"Distance (km)" -Bya50f10+l"Depth (km)" -BWeStr


echo "plot bathymetry Fig (B)-1"
gmt project -C$start -E$end -G1 -Q -V > track.xyp
gmt grdtrack track.xyp -G$grd2 -V > track.xypz
awk '{print $3,$4*-0.001}' track.xypz > track_profile.txt

echo "plot bathymetry Fig (B)-2"
gmt plot track_profile.txt -Y${jx}  -R0/${proj_profile_km}/0/3 -JX15c/-1.5c -Bx100f50 -Bya2f0.5+l"Bathymetry (km)" -BEswn -W2p,grey -Ggrey -L+yt -V  #-L+yt (colored range) #-Y${jx}
#gmt plot track_profile.txt  -R0/${proj_profile_km}/0/5 -JX15c/-1.5c   -Beswn -W0.01p,#95FAF9@30   -G#95FAF9@30  -L+yb -V  #-L+yt (colored range)



gmt end show
now=$(date +"%T")
echo "Current time : $now"
rm gmt.history gmt.conf L_index_0.gmt
