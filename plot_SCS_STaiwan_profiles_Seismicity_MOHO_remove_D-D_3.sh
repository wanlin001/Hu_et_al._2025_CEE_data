#!/bin/csh -x
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
# from Taiwan_GPS_Seismicity_profile4.sh
#Taiwan GPS and seismicityCSV
#4 change legend

# To add in:
# auto BATS-focal mechanisms: https://tecws1.earth.sinica.edu.tw/AutoBATS/
#problem to be solved: font color of scales
# to do: FMs' shear sense and size Mw
# FM only for half year

#ogr2ogr -f "GMT" 2019_Gozzard_inverted_MOHO_depth.gmt  2019_Gozzard_inverted_MOHO_depth.shp
#ogr2ogr -f "GMT" ManilaTrench.gmt  ManlaTrench.shp

#extract data from original Wu relacation
# cat Wu_relocation_orig.txt|awk '{printf "%f %f %f %.5f\n", $9+$10/60,$7+$8/60 , $11, $18}' > Wu_relocation.dat

Profile_seismicity=./data/Wu_relocate_selected.dat
#gmt set TICK_LENGTH 									 = 0.2c
gmt set MAP_FRAME_AXES                 = WESNZ
gmt set MAP_FRAME_PEN                  = thicker,black
gmt set MAP_FRAME_TYPE                 = fancy+ #plain
gmt set MAP_DEGREE_SYMBOL							 = degree
gmt set MAP_FRAME_WIDTH                = 3p
gmt set MAP_ANNOT_MIN_ANGLE            = 20
## FONT Parameters
gmt set FONT_ANNOT_PRIMARY             = 14p,0,black
gmt set FONT_ANNOT_SECONDARY           = 12p,0,black
gmt set FONT_HEADING                   = 20p,0,black
gmt set FONT_LOGO                      = 8p,0,black
gmt set FONT_TAG                       = 20p,0,black
gmt set FONT_TITLE                     = 20p,0,black
gmt set MAP_TITLE_OFFSET 							 = 0.8c
## For setting scale
gmt set FONT_LABEL                     = 12p,0,black
gmt set MAP_SCALE_HEIGHT							 = 8p
gmt set MAP_TICK_PEN_PRIMARY					 = thinner,black
gmt set MAP_DEFAULT_PEN								 = thinner,black

#gmt set PS_CONVERT         = ""
#gmt set MAP_ORIGIN_X=0c
#gmt set MAP_ORIGIN_Y=c
#gmt set PS_PAGE_ORIENTATION=portrait
#gmt set PS_MEDIA = A0
gmt set FORMAT_GEO_MAP=ddd:mm:ssG
#gmt default -D
#gmt defaults -D > ~/gmt.conf
## Declare files and directories   #variables= (note: no space left...)
DATAdir=/Users/wanlin/Documents/05.Taiwan/03.2006_earthquake_doublet/022.plotting_figures/data
DATAdir2=/Users/wanlin/Documents/05.Taiwan/00.data/03.seismicity
DATAdir3=/Users/wanlin/Documents/05.Taiwan/03.2006_earthquake_doublet/021.Northern_Manila/data
DATAdir4=/Users/wanlin/Documents/05.Taiwan/03.2006_earthquake_doublet/021.Northern_Manila/refs_data
outputfiledir=./outputPDF

#plotting files
slab2=$DATAdir/man_slab2_dep_02.24.18.grd
MOHOdepth1=$DATAdir3/2019MOHO.csv
MOHOdepth2=$DATAdir4/2021_GandH_MOHO.dat
Shoreline_dot=$DATAdir3/Shoreline_dot.csv
ManilaTrench_dot=$DATAdir3/ManilaTrench_dot.csv
SL_MOHO_num=$DATAdir3/Seismic_Lines_MOHO_remove_DD.csv


Bathymetry=$DATAdir/gebco_2023.nc
shoreline=/Users/wanlin/Documents/05.Taiwan/00.data/00.GIS_shp/Tw_shoreline.txt



seismic_color=grey@30
seismic_color_bar=grey@30
## Declare region parameters
west=118.447
east=122.4
south=21.1
north=23.6

#314.5 km
#Midpoint:	21° 50′ 38″ N, 120° 46′ 35″ E

start=119.028/22.195
end=122.045/22.195
proj_profile_km=310
### Profiles  ###
start1=119.028/23.195
end1=122.045/23.195

start2=119.028/22.723
end2=122.045/22.723


start3=119.028/22.195
end3=122.045/22.195

start4=119.028/21.514
end4=122.045/21.514


proj=M15c # Mercator projection with plot width 15 cm
range="${west}/${east}/${south}/${north}"
borderx=a1f0.5g1    #a: annotation, f: font, g: grid (will be covered by image), lable, a10f5g10
bordery=a1f0.5g1
bordershow=ENws
title=" " #"Profiles of MOHO depth and Seismicity"
grd2=cut.nc
#gmt grdcut @earth_relief_15s -G$grd2 -R$range

#115.1133830654,17.5560347882,126.5623472009,28.7798761638

#make once cut
# Do only once
#gmt grdcut @earth_relief_15s -G$grd2 -R$range
#profile label style
txt_font=16p,1,black #=0.1p,white
txt_note_shift=0.05c/0.1c
txt_loc=T #TCB
color_lb=0.3p,black@50,solid
color_lb_fill=white@10
conor=10%/10%  # for  %-C
############################################

gmt begin ${outputfiledir}/plot_STaiwan_profiles_Seismicity_MOHO_rmvDD3 pdf A+m0.3c #eps,PNG



echo "***************** plot SCS overview map *****************"
#scs_range=108.22/122.5/7.77/25.12
#89.99,-0.71,148.39,45.05
scs_range=110.74/129.73/15.43/28.65

##gmt grdcut @earth_relief_15s -Gscs.grd -R$scs_range
gmt basemap  -JM7.5c -R$scs_range -Bxa -Bya -BWNse --MAP_FRAME_TYPE=plain
#gmt makecpt -Cgray -T-6000/4000 -Z -V
#gmt grdimage  scs.grd
gmt coast -Ggray@40 -Df -W0.1p,black #-N1/0.5p,red #-Ia/0.25p,blue
gmt plot PB2002_plates.dig.txt  -W0.5p,gray #PB2002_boundaries.dig.txt
gmt plot   ${DATAdir3}/ManilaTrench.gmt -W1p,black,solid -Gblack -Sf0.6c/0.1c+r+t -I0
gmt plot  ${DATAdir3}/COB_ref.gmt -W1p,orange,solid -I1
echo "127 18 PHP" | gmt text -F+f16p,Helvetica-Bold,black+jCM -N #-Gwhite@50
echo "115 27 EUR" | gmt text -F+f16p,Helvetica-Bold,black+jCM -N #-Gwhite@50
echo "117.5 16.5 SCS" | gmt text -F+f13p,Helvetica,black+jCM -N #-Gwhite@50
echo "114 16.8 oceanic-cont. boundary" | gmt text -F+f10p,Helvetica,orange+jCM+a25 -N -Gwhite@50
echo "113 19.8 cont.-thinned cont. transition" | gmt text -F+f10p,Helvetica,orange+jCM+a25 -N -Gwhite@50
echo "125.4 20 Manila Trench" | gmt text -F+f12p,Helvetica,black+jCM -N
echo "122.5 24 B" | gmt text -F+f12p,Helvetica,red+jCM -N -Gwhite@10

echo "draw a box indicating zoom in area: 120.1/120.8/21.3/22.45"
gmt plot  -W1p,red << EOF
$west $south
$east $south
$east $north
$west $north
$west $south
EOF
prof_no='A'
echo ${prof_no} | gmt text  -F+f${txt_font}+c${txt_loc}L -Dj${txt_note_shift} -W${color_lb} -G${color_lb_fill} -C$conor


#gmt set PS_MEDIA = A0
echo "*****************plot basemap*****************"
	gmt basemap -Y-12c -J${proj} -R${range} -Bx${borderx}+l"Lon." -By${bordery}+l"Lat." -B${bordershow}+t"${title}"

	##gmt makecpt -Cgeo -T-6000/4000 -Z -V >topotw.cpt
	##gmt makecpt -Cgeo -T-6000/4000 -Z -V >topotw.cpt
##############################################################
#gmt makecpt -Celevation -T0/3900 -Z -V > topo.cpt
#gmt makecpt -Ccopper -T0/3900 -Z -V -Iz > topo.cpt
#gmt makecpt -CgrayC -T-5500/0/5 -V -Iz >gray.cpt #-Iz
#gmt makecpt -CgrayC -T0/5500 -Z -V  >gray_bar.cpt
	#sea
	gmt grdimage -J${proj} -R${range} $grd2  -Cgray.cpt -I+d  # ../00.data/DEM/GEBCO_2021.nc ../00.data/DEM/GEBCO_2021.nc
	gmt coast -J${proj} -R${range} -Df -Gc
	#Land
	gmt grdimage $grd2 -J${proj} -R${range} -Ctopo.cpt -I+d # -Ne #change cpt
	gmt coast -J${proj} -R${range} -Df -Q
	#gmt coast -J${proj} -R${range} -IA -W1p -Df -Q -V
#slab2 countour; labeling interval -A50 -Cline
	#gmt grdcontour $slab2 -C10 -A100f7p -J${proj} -R${range} -Wathick,blue -Wcthin,blue@30,-
## plot structural lines
echo "structural line, maybe move to subplot"
gmt plot -J${proj} -R${range}  ${DATAdir3}/Taiwan_faultlines.gmt -W1p,black@30 -I1
gmt plot -J${proj} -R${range}  ${DATAdir3}/ManilaTrench.gmt -W3p,black@20,- -Gblack -Sf2.5c/0.3c+r+t -I0
gmt plot -J${proj} -R${range}  ${DATAdir3}/COB_ref.gmt -W5p,orange,..- -I1
prof_no='B'
echo ${prof_no} | gmt text  -F+f${txt_font}+c${txt_loc}L -Dj${txt_note_shift} -W${color_lb} -G${color_lb_fill} -C$conor

echo "***************** plot text-Fault *****************"
faulttxtcolor=18p,1,black=0.6p,white,solid

#echo 120 21.3  $faulttxtcolor 120 CM 'MT'  > faulttext
echo 119.6 22.5  $faulttxtcolor 45 CM 'DF' >> faulttext
#echo 118.7 21.6  22p,1,black=0.6p,white,solid  30 CM 'COB' >> faulttext
#echo 102.5 34.62      $faulttxtcolor -7 CM 'Kunlun Fault' >> faulttext
#echo 98 31.8        $faulttxtcolor -30 CM 'Xianshuihe Fault' >> faulttext
#echo 94 29.8        $faulttxtcolor -15 CM 'Jiali Fault' >> faulttext
gmt text faulttext -F+f+a+j -N -C0.1c+tO -Gwhite@50

##
echo "####plot MOHO on map view add in color scale####"
cat moho2.xyz|gmt plot  -J${proj} -R${range} -St0.25c -Ggreen -h1 -W0.1p

#cat moho2.xyz | gmt text -F+f10p,29+jCM -N -V
#|gmt text  -J${proj} -R${range} -Sp0.25c -Ggreen -h1 -W0.1p -V 10p,29 CM 5 | gmt text -F+f+j -N -V


echo "plot index line"


gmt set PS_LINE_CAP=round #SQUARE #Line cap become rounded
# profile 1
prof_no=C
echo $start1 $end1 |awk '{split($1,a,"/") split ($2,b,"/"); printf "%f %f \n%f %f", a[1], a[2], b[1], b[2]}'>profile.se
gmt plot profile.se -J${proj} -R${range} -Sf-2/1c -I1  -W3p,red
gmt plot profile.se -J${proj} -R${range} -Sf-2/1c -I1  -W1p,white
#$(awk 'NR==2' profile.se)
echo $(awk 'NR==1' profile.se) ${prof_no} | gmt text -F+f${txt_font}+j${txt_loc}L -Dj${txt_note_shift} -W${color_lb} -G${color_lb_fill} -C$conor
echo $(awk 'NR==2' profile.se) ${prof_no}\' | gmt text  -F+f${txt_font}+j${txt_loc}R -Dj${txt_note_shift} -W${color_lb} -G${color_lb_fill} -C$conor

# profile 2
prof_no=D
echo $start2 $end2 |awk '{split($1,a,"/") split ($2,b,"/"); printf "%f %f \n%f %f", a[1], a[2], b[1], b[2]}'>profile.se
gmt plot profile.se -J${proj} -R${range} -Sf-2/1c -I1  -W3p,red
gmt plot profile.se -J${proj} -R${range} -Sf-2/1c -I1  -W1p,white
echo $(awk 'NR==1' profile.se) ${prof_no} | gmt text -F+f${txt_font}+j${txt_loc}L -Dj${txt_note_shift} -W${color_lb} -G${color_lb_fill} -C$conor
echo $(awk 'NR==2' profile.se) ${prof_no}\' | gmt text  -F+f${txt_font}+j${txt_loc}R -Dj${txt_note_shift} -W${color_lb} -G${color_lb_fill} -C$conor


# profile 3
prof_no=E
echo $start3 $end3 |awk '{split($1,a,"/") split ($2,b,"/"); printf "%f %f \n%f %f", a[1], a[2], b[1], b[2]}'>profile.se
gmt plot profile.se -J${proj} -R${range} -Sf-2/1c -I1  -W3p,red
gmt plot profile.se -J${proj} -R${range} -Sf-2/1c -I1  -W1p,white
echo $(awk 'NR==1' profile.se) ${prof_no} | gmt text -F+f${txt_font}+j${txt_loc}L -Dj${txt_note_shift} -W${color_lb} -G${color_lb_fill} -C$conor
echo $(awk 'NR==2' profile.se) ${prof_no}\' | gmt text  -F+f${txt_font}+j${txt_loc}R -Dj${txt_note_shift} -W${color_lb} -G${color_lb_fill} -C$conor


# profile 4
#prof_no=D
#echo $start4 $end4 |awk '{split($1,a,"/") split ($2,b,"/"); printf "%f %f \n%f %f", a[1], a[2], b[1], b[2]}'>profile.se
#gmt plot profile.se -J${proj} -R${range} -Sf-2/1c -I1  -W3p,red
#gmt plot profile.se -J${proj} -R${range} -Sf-2/1c -I1  -W1p,white
#echo $(awk 'NR==1' profile.se) ${prof_no} | gmt text -F+f${txt_font}+j${txt_loc}L -Dj${txt_note_shift} -W${color_lb} -G${color_lb_fill} -C$conor+tO
#echo $(awk 'NR==2' profile.se) ${prof_no}\' | gmt text  -F+f${txt_font}+j${txt_loc}R -Dj${txt_note_shift} -W${color_lb} -G${color_lb_fill} -C$conor+tO



gmt set PS_LINE_CAP=SQUARE  #round be back

####
echo "@@@ Plot seismic line in map view @@@@"
cat $SL_MOHO_num |awk -F "," '{ printf "%f %f %d\n", $1, $2, $4}'> SLmoho.xyt

gmt plot SLmoho.xyt -J${proj} -R${range} -W0.25p -Gpurple -t20 -Sc0.25c #for circle
cat SLmoho.xyt |gmt text -J${proj} -R${range}  -F+jCM+f5p,1,white=0.25p,black,solid #for text

#Wu relocation, plot horizontal uncertainty
# plot map view seismicity
cat ${DATAdir4}/2006_2007_relocationHC_2.dat| gmt plot  -J${proj} -R${range} -Sp0.025c -Gblack@40 #$seismic_color


echo "### plot mainshock on the map ###"


cat <<EOF >mainshock.dat
120.5553 21.6873 38.11
120.4197 21.9698 55.22
EOF

gmt plot mainshock.dat -Sa0.4c -Gred -W1p
echo "120.19 21.95 Event #2" | gmt text -F+f8p,Helvetica-Bold,black+jCM -N -Gwhite@50
echo "120.35 21.69 Event #1" | gmt text -F+f8p,Helvetica-Bold,black+jCM -N -Gwhite@50

echo "draw a box indicating zoom in area: 120.1/120.8/21.3/22.45"
gmt plot  -W1p,red << EOF
120.1 21.3
120.8 21.3
120.8 22.45
120.1 22.45
120.1 21.3
EOF
#####
echo "120.4 21.38 Fig. 2A" | gmt text -F+f12p,Helvetica,red+jCM -N -Gwhite@50

# PROJECTION #
#### plot profile lines
## Accessory :north indication (-TdjTL) and scale (-Lx...)20p,1,white=1p,black,solid
echo "*****************Plot  Accessory *****************"
gmt basemap -TdjTL+o0.2c/0.2c+w1.5c+l,,,N+f  -Lx2.5c/0.6c+c22+w50k+f1+u --MAP_TITLE_OFFSET=0.2c  --FONT_TITLE=15p,1,black  --FONT_ANNOT_PRIMARY=12p,1,white=0.5p,black,solid   #--FONT_LABEL=12p,31,white=0.3p,black,solid #-Lg110/-15+c0+w1000k+l+f2 -V
gmt colorbar  -Dx-1.2c/7c+w2.6c/0.2c+jTC+v+ml -Ctopo.cpt  -Baf+l"Elevation (m)" -S --FONT_ANNOT_PRIMARY=20p --FONT_LABEL=24p #-Bxa100f50 #negative length or append +r (in-R) to reverse colorbar
gmt colorbar  -Dx-1.2c/3c+w2.5c/0.2c+jTC+v+ml -Baf+l"Bathymetry (m)" -Cgray.cpt -S --FONT_ANNOT_PRIMARY=20p --FONT_LABEL=24p
#	gmt colorbar  -Dx16c/7c+w2.5c/0.2c+jTC+v+mcl -Baf+l"Elevation (km)" -Ctopo.cpt+Ukm -S -I -V










echo "#################subplot set#################"


jx=3 #height of seisplot, scale of y
# remeber to modify the -Y below
jd=0.6 #distance from the previous basemep
depth=80

rightshift=16c
upshift=4.0c

prof_R=0/${proj_profile_km}/-1/${depth}
prof_J=X15c/-${jx}c

echo "# Fig (C) background seismicity # "



# MOHO1 from Gozzard et al., 2019: lon, lat, depth
cat $MOHOdepth1  | awk -F "," '{printf "%f %f %f %.1f\n", $1,$2,$3,$3}' > moho.xyz
# MOHO2: refs G and Hung, 2021's MOHO from reciever function: lon, lat, depth, err, station names
cat $MOHOdepth2 |awk '{printf "%.2f %.2f %.1f %.1f %s\n", $3, $2, $4, $5, $1}' >moho2.xyz
# shoreline; lon, lat
cat $Shoreline_dot  | awk -F "," '{printf "%.2f %.2f \n", $1,$2}' > shoreline.xy
# Manila trench: lon, lat
cat $ManilaTrench_dot  | awk -F "," '{printf "%.2f %.2f \n", $1,$2}' > MT.xy
# Seismic Line, MOHO and line number
cat $SL_MOHO_num |awk -F "," '{ printf "%.2f %.2f %.2f %d \n", $1, $2, $3, $4}'> SLmoho.xyzn

#########


echo "style setting"

#profile label style
txt_font=15p,1,black #=0.1p,white
txt_note_shift=0.25c/0.25c
txt_loc=B #TCB
color_lb=0.3p,black@50,solid
color_lb_fill=white@30
conor=10%/10%  # for  %-C
############################################





###################



echo "plot bathymetry Fig (B)-0"
start=$start1
end=$end1
prof_no=C

upshift=-3.5c

gmt basemap  -Y$upshift   -R${prof_R} -J${prof_J} -Bya40f10+l" " -BwnEs -Bxa100f10
#echo "T4A" |gmt text  -F+f5.5p,1,black+cBL -Dj1c/1c  -Gyellow@50 -TO -C10%/10% -V
# plot slab2

#label for profiles
echo ${prof_no} | gmt text  -F+f${txt_font}+c${txt_loc}L -Dj${txt_note_shift} -W${color_lb} -G${color_lb_fill} -C$conor
echo ${prof_no}\' | gmt text  -F+f${txt_font}+c${txt_loc}R -Dj${txt_note_shift} -W${color_lb} -G${color_lb_fill} -C$conor


gmt project -C$start -E$end -G1 -Q  |gmt grdtrack -G$slab2 |awk '{if($4 !="NaN") printf "%d %.3f\n",$3, $4*-1}' > track.pz
gmt plot track.pz   -R${prof_R} -J${prof_J} -A -W2p,blue -Fa

#plot seismicity


cat $Profile_seismicity |gmt project -C${start} -E${end}  -Fpz -Lw -W-20/20 -Q | gmt plot  -R${prof_R} -J${prof_J} -W0.25p -G$seismic_color  -Sp0.025c -Ey+w0c+p0.1p,$seismic_color_bar

#plot MOHO1 from Gozzard et al., 2019
## NOTES project data to profiles ###

#-W ploting within width (km)
#plot MOHO1 from Gozzard et al., 2019
gmt coupe moho.xyz  -R${prof_R} -J${prof_J}  -Fsd0.25c -W1p,green -t10 -Gred -Aa${start}/${end}/90/25/0/${proj_profile_km}
cat moho2.xyz |gmt project -C${start} -E${end}  -Fpz -Lw -W-40/40 -Q  |  gmt plot -R${prof_R} -J${prof_J} -W1p -Ggreen -t10 -St0.3c -Ey
cat shoreline.xy |gmt project -C${start} -E${end}  -Fp -Lw -W-30/30 -Q  |awk '{printf "%.3f -5\n",$1}'|  gmt plot -R${prof_R} -J${prof_J} -W1p -Ggoldenrod -t10 -Si0.4c -N
cat MT.xy |gmt project -C${start} -E${end}  -Fp -Lw -W-10/10 -Q   |awk '{printf "%.3f -5\n",$1}'|  gmt plot -R${prof_R} -J${prof_J} -W1p -Gdarkblue -t10 -Si0.4c -N









#profile 1
echo "plot bathymetry Fig (B)-1"
start=$start2
end=$end2
prof_no=D

#gmt basemap  -Y-h-${jd}c   -R${prof_R} -J${prof_J}  -Bya40f10+l"T4A"  -BwEst -Bxa100f10
gmt basemap  -Y-h-${jd}c   -R${prof_R} -J${prof_J}  -Bya40f10+l"Depth (km)"  -BwEst -Bxa100f10
#echo "T4A" |gmt text  -F+f5.5p,1,black+cBL -Dj1c/1c  -Gyellow@50 -TO -C10%/10% -V
#label for profiles
echo ${prof_no} | gmt text  -F+f${txt_font}+c${txt_loc}L -Dj${txt_note_shift} -W${color_lb} -G${color_lb_fill} -C$conor
echo ${prof_no}\' | gmt text  -F+f${txt_font}+c${txt_loc}R -Dj${txt_note_shift} -W${color_lb} -G${color_lb_fill} -C$conor

echo "T4A" | gmt text  -F+f14p,0,black+cLL -Dj1.2c/0.3c #-W0p,black@50,solid -Gwhite@10


# plot slab2
gmt project -C$start -E$end -G1 -Q  |gmt grdtrack -G$slab2 |awk '{if($4 !="NaN") printf "%d %.3f\n",$3, $4*-1}' > track.pz
gmt plot track.pz   -R${prof_R} -J${prof_J} -A -W2p,blue,- -Fa

#plot seismicity

cat $Profile_seismicity |gmt project -C${start} -E${end}  -Fpz -Lw -W-20/20 -Q | gmt plot  -R${prof_R} -J${prof_J} -W0.25p -G$seismic_color   -Sp0.025c -Ey+w0c+p0.1p,$seismic_color_bar


#plot MOHO1 from Gozzard et al., 2019
gmt coupe moho.xyz  -R${prof_R} -J${prof_J}  -Fsd0.25c -W1p,green -t10 -Gred -Aa${start}/${end}/90/25/0/${proj_profile_km}

## NOTES project data to profiles ###
# refs G and Hung, 2021's MOHO from reciever function
cat moho2.xyz |gmt project -C${start} -E${end}  -Fpz -Lw -W-20/20 -Q  |  gmt plot -R${prof_R} -J${prof_J} -W1p -Ggreen -t10 -St0.3c -Ey
#-W ploting within width (km)
# plot TAIGER project profile number index
# plot shoreline indicators

cat shoreline.xy |gmt project -C${start} -E${end}  -Fp -Lw -W-30/30 -Q  |awk '{printf "%.3f -5\n",$1}'|  gmt plot -R${prof_R} -J${prof_J} -W1p -Ggoldenrod -t10 -Si0.4c -N
# plot Manila trench indicators

cat MT.xy |gmt project -C${start} -E${end}  -Fp -Lw -W-10/10 -Q   |awk '{printf "%.3f -5\n",$1}'|  gmt plot -R${prof_R} -J${prof_J} -W1p -Gdarkblue -t10 -Si0.4c -N

cat SLmoho.xyzn|awk '{if ($3>0) print "%f %f %f\n",$1,$2,$3}'|gmt project -C${start} -E${end}  -Fpz -Lw -W-20/20 -Q  |  gmt plot -R${prof_R} -J${prof_J} -W1p -Gyellow -t10 -Ss0.3c
cat SLmoho.xyzn|gmt project -C${start} -E${end}  -Fpz -Lw -W-20/20 -Q  |awk '{ printf "%.f -5 %.2f %d\n", $1, $2,$3}'> SLnumber
gmt plot SLnumber -R${prof_R} -J${prof_J} -W0.25p -Gpurple -t10 -N -Sc0.2c #for circle
cat SLnumber |awk '{printf "%f %f %d\n", $1,$2,$4}'|gmt text -R${prof_R} -J${prof_J}  -F+jCM+f5p,1,white=0.25p,black,solid -N #for text



#profile 2
echo "plot bathymetry Fig (B)-2"

start=$start3
end=$end3
prof_no=E
#gmt basemap -Y-h-${jd}c   -R${prof_R} -J${prof_J} -Bya40f10+l"T2933"  -Bxa100f10+l"Distance (km)"  -BwESt
gmt basemap -Y-h-${jd}c   -R${prof_R} -J${prof_J} -Bya40f10+l" "  -Bxa100f10+l"Distance (km)"  -BwESt
#label for profiles
echo ${prof_no} | gmt text  -F+f${txt_font}+c${txt_loc}L -Dj${txt_note_shift} -W${color_lb} -G${color_lb_fill} -C$conor
echo ${prof_no}\' | gmt text  -F+f${txt_font}+c${txt_loc}R -Dj${txt_note_shift} -W${color_lb} -G${color_lb_fill} -C$conor
echo "T2933" | gmt text  -F+f14p,0,black+cLL -Dj1.2c/0.3c

cat $Profile_seismicity |gmt project -C${start} -E${end}  -Fpz -Lw -W-20/20 -Q | gmt plot -R${prof_R} -J${prof_J} -W0.25p -G$seismic_color  -Sp0.025c -Ey+w0c+p0.1p,$seismic_color_bar
cat mainshock.dat|gmt project -C${start} -E${end}  -Fpz -Lw -W-80/20 -Q | gmt plot  -R${prof_R} -J${prof_J} -W1p -Gred   -Sa0.35c
echo "135 65 Event #2" | gmt text -F+f8p,Helvetica-Bold,black+jCM -N -Gwhite@50
echo "172 42 Event #1" | gmt text -F+f8p,Helvetica-Bold,black+jCM -N -Gwhite@50



gmt project -C$start -E$end -G1 -Q  |gmt grdtrack -G$slab2 |awk '{if($4 !="NaN") printf "%d %.3f\n",$3, $4*-1}' > track.pz
gmt plot track.pz   -R${prof_R} -J${prof_J} -A -W2p,blue -Fa
gmt coupe moho.xyz  -R${prof_R} -J${prof_J} -Fsd0.25c -W1p,green -t10 -Gred -Aa${start}/${end}/90/25/0/${proj_profile_km}
cat moho2.xyz |gmt project -C${start} -E${end}  -Fpz -Lw -W-40/20 -Q  |  gmt plot -R$prof_R  -JX15c/-${jx}c -W1p -Ggreen -t10 -St0.3c -Ey
cat shoreline.xy |gmt project -C${start} -E${end}  -Fp -Lw -W-30/30 -Q  |awk '{printf "%.3f -5\n",$1}'|  gmt plot -R${prof_R} -J${prof_J} -W1p -Ggoldenrod -t10 -Si0.4c -N
cat MT.xy |gmt project -C${start} -E${end}  -Fp -Lw -W-30/30 -Q   |awk '{printf "%.3f -5\n",$1}'|  gmt plot -R${prof_R} -J${prof_J} -W1p -Gdarkblue -t10 -Si0.4c -N

cat SLmoho.xyzn|awk '{if ($3>0) print "%f %f %f\n",$1,$2,$3}'|gmt project -C${start} -E${end}  -Fpz -Lw -W-20/20 -Q  |  gmt plot -R${prof_R} -J${prof_J} -W1p -Gyellow -t10 -Ss0.3c
cat SLmoho.xyzn|gmt project -C${start} -E${end}  -Fpz -Lw -W-20/20 -Q  |awk '{printf "%.f -5 %.2f %d\n", $1, $2,$3}'> SLnumber
gmt plot SLnumber -R${prof_R} -J${prof_J} -W0.25p -Gpurple -t10 -N -Sc0.2c #for circle
cat SLnumber |awk '{printf "%f %f %d\n", $1,$2,$4}'|gmt text -R${prof_R} -J${prof_J}  -F+jCM+f5p,1,white=0.25p,black,solid -N #for text##

#profile 3
#echo "plot bathymetry Fig (B)-3"

#start=$start4
#end=$end4
#prof_no=D

#gmt basemap -X16c -Y$upshift -R${prof_R} -J${prof_J} -Bya40f10+l"Depth (km)" -BwESt -Bxa100f10
#gmt basemap -Y-h-${jd}c  -R${prof_R} -J${prof_J} -Bya40f10+l"T2" -Bxa100f10+l"Distance (km)"  -BwESt

#label for profiles
#echo ${prof_no} | gmt text  -F+f${txt_font}+c${txt_loc}L -Dj${txt_note_shift} -W${color_lb} -G${color_lb_fill} -C$conor
#echo ${prof_no}\' | gmt text  -F+f${txt_font}+c${txt_loc}R -Dj${txt_note_shift} -W${color_lb} -G${color_lb_fill} -C$conor
#cat $Profile_seismicity|gmt project -C${start} -E${end}  -Fpz -Lw -W-20/20 -Q | gmt plot  -R${prof_R} -J${prof_J} -W0.25p -G$seismic_color   -Sp0.025c -Ey+w0c+p0.1p,$seismic_color_bar
## Step 1: Calculate the density of seismicity
##### NOTES: extract info from grd and prject to assigned profiles #####
### 生成資料剖面 slab2 ###
#gmt project -C$start -E$end -G1 -Q -V > track.xyp
#gmt grdtrack track.xyp -G$slab2 -V > track.xypz
#cat track.xypz|awk '{if($4 !="NaN") printf "%d %.3f\n",$3, $4*-1}' > track.pz
##
#project:生成剖面線段; -G：interval; 生成檔案track.xyp：lon,lat,沿profile距離
#grdtrack:擷取沿此線段(track.xyp)上，檔案中-G(grd or nc)的值;生成檔案track.xypz
#data parsing:整理一下檔案，去除NaN的資料; gmt project, plot上剖面
#可以簡寫成以下指令： “|”代表把前面指令輸出的成果餵給後面指令，可以減少中間檔案，但是若需要重複使用，生成檔案可以減少運算時間。
gmt project -C$start -E$end -G1 -Q  |gmt grdtrack -G$slab2 |awk '{if($4 !="NaN") printf "%d %.3f\n",$3, $4*-1}' > track.pz
gmt plot track.pz  -R${prof_R} -J${prof_J} -A -W2p,blue -Fa
##### extract info from grd and prject to assigned profiles #####

#gmt project -C$start -E$end -G1 -Q  >track.xyp
#gmt grdtrack track.xyp -G$slab2 |awk '{if($4 !="NaN") printf "%d %.3f\n",$3, $4*-1}' -V > track.pz
#gmt plot track.pz   -R$prof_R  -JX15c/-${jx}c -A -W1p,blue -Fa -V

## plot xyz data to profile
## coupe 也可以拿來投影一般的資料點,用-Fs?來指定形狀
# plot MOHO depth from refs (Gozzard et al., 2019)

# project xyz data to profile
#echo 102 30 | gmt project -C103/31 -A225 -L0/500 -Frs -Q >test.pdf

#gmt plot  -J${proj} -R${range} -Sp0.01c -Gred -h1 -W0.01p -V
#-L+yt (colored range) #-Y${jx}



gmt coupe moho.xyz  -R${prof_R} -J${prof_J}  -Fsd0.25c -W1p,green -t10 -Gred -Aa${start}/${end}/90/25/0/${proj_profile_km}
cat moho2.xyz |gmt project -C${start} -E${end}  -Fpz -Lw -W-20/20 -Q  |  gmt plot -R${prof_R} -J${prof_J} -W1p -Ggreen -t10 -St0.3c -Ey
cat shoreline.xy |gmt project -C${start} -E${end}  -Fp -Lw -W-30/30 -Q  |awk '{printf "%.3f -5\n",$1}'|  gmt plot -R${prof_R} -J${prof_J} -W1p -Ggoldenrod -t10 -Si0.4c -N
cat MT.xy |gmt project -C${start} -E${end}  -Fp -Lw -W-10/10 -Q   |awk '{printf "%.3f -5\n",$1}'|  gmt plot -R${prof_R} -J${prof_J} -W1p -Gdarkblue -t10 -Si0.4c -N

cat SLmoho.xyzn|awk '{if ($3>0) print "%f %f %f\n",$1,$2,$3}'|gmt project -C${start} -E${end}  -Fpz -Lw -W-20/20 -Q |  gmt plot -R${prof_R} -J${prof_J} -W1p -Gyellow -t10 -Ss0.3c
cat SLmoho.xyzn|gmt project -C${start} -E${end}  -Fpz -Lw -W-20/20 -Q  |awk '{printf "%.f -5 %.2f %d\n", $1, $2,$3}'> SLnumber
gmt plot SLnumber -R${prof_R} -J${prof_J} -W0.25p -Gpurple -t10 -N -Sc0.2c #for circle
cat SLnumber |awk '{printf "%f %f %d\n", $1,$2,$4}'|gmt text -R${prof_R} -J${prof_J}  -F+jCM+f5p,1,white=0.25p,black,solid -N #for text


#cat chang2022_2006.dat | awk '{ print $1, $2, $3, $4 }' |gmt project -C${start} -E${end}  -Fpz -Lw -W-30/30 -Q | gmt plot   -Sp0.05c -Gblue
#cat chang2022_2005.dat | awk '{ print $1, $2, $3, $4 }' |gmt project -C${start} -E${end}  -Fpz -Lw -W-30/30 -Q  | gmt plot   -Sp0.05c -Gred

echo "*****************Plot  Legend for map and profile *****************"
#echo 119.6 22.5 18p,1,black=0.6p,white,solid 45 CM 'DF' |gmt text  -F+f+a+j -N -C0.1c+tO -Gwhite@50
#echo 121.5 25 12p,1,black 0 CM "Legends" |gmt text  -F+f+a+j -N  #-F+f12.5p,1,black+cBL -Dj2.75c/-1.5c  -N #-Ggrey@50  -C60%/60% -V
gmt set FONT_ANNOT_PRIMARY 9p
# -Dx-0.1c/-5.2c+w7.5c+jBL+l1.1 -C0.1c/0.1c -F+p+glightgrey@70+r  << EOF
gmt legend -Dx+8.3c/+25.9c+w7.5c+jBL+l1.1 -C0.1c/0.1c -F+p+glightgrey@70+r  << EOF
# G is vertical gap, V is vertical line, N sets # of columns, D draws horizontal line,
# H is ps=legend.ps
#
# G -0.1i
# H 10p,Times-Roman Legend
# D 0.2i 1p
N 1
H 10p,1 Map
S 0.3c  c 0.3c purple 0.25p 0.3i   Stations for tomography (TAIGER exp.)
S 0.3c  t 0.3c green 	0.25p 0.3i   Stations for receiver function
S 0.3c  a 0.35c red 0.25p   0.3i  Mainshocks of the 2006 EQ doublet
S 0.3c  p 0.1c black 0.25p 0.3i  Seismicity
#S 0.3c  - 0.5c  - 1p,blue,- 0.3i Slab2: Interface depth
S 0.3c  f1c/0.05i+l+t 0.5c black 0.5p 0.3i  Deformation front (DF)
S 0.3c  - 0.5c - 	2p,orange,..- 0.3i Transition of cont.-thinned cont.
EOF
#dx1 symbol size fill pen [ dx2 text ]
# (Goyal & Hung, 2021)
gmt legend -Dx8.3c/+21.95c+w7.5c+jBL+l1.1 -C0.1c/0.1c -F+p+glightgrey@70+r -B+t"Profiles"  << EOF
# G is vertical gap, V is vertical line, N sets # of columns, D draws horizontal line,
# H is ps=legend.ps
#
# G -0.1i
# H 12p,Times-Roman Legend
# D 0.2i 1p
N 1
#V 0 1p
#S 0.4c c 0.15i p300/12 0.25p 0.3i This circle is hachured
#S [dx1 symbol size fill pen [ dx2 text ]]
H 10p,1 Profiles
S 0.3c  c 0.3c purple 0.25p 0.3i  Stations for tomography (TAIGER exp.)
S 0.3c  s 0.3c yellow 0.5p 0.3i Moho by TAIGER exp.
S 0.3c  t 0.3c green 	0.25p 0.3i Moho by receiver function
S 0.3c  d 0.3c red    0.5p 0.3i Moho by gravity inversion
S 0.3c  a 0.35c red 0.25p   0.3i Mainshocks of the 2006 EQ doublet
S 0.3c  p 0.1c black 0.25p 0.3i Seismicity
S 0.3c  - 0.5c  - 1p,blue,- 0.3i Slab2 interface
S 0.3c  i 0.3c goldenrod 		0.5p 0.3i Coastline
S 0.3c  i 0.3c darkblue 	0.5p 0.3i Deformation front 
EOF
echo  "Legends" |gmt text  -F+f12.5p,1,black+cBL -Dj11.1c/28.9c  -N #-Ggrey@50  -C60%/60% -V





gmt end show
rm faulttext
