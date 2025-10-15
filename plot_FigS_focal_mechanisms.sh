#!/usr/bin/env -S gmt6 run

# Create a data file with six focal mechanisms using full moment tensor format
#longitude latitude depth value T_az T_pl N_az N_pl P_az P_pl exp [newX newY] [event_title]
cat << EOF > focal_mechanisms0.dat
0 0 10  3.603e+19 59 23 0.294e+19   324 11 -3.898e+19	210	64 26 0 0 USGS 1@-st@-
2 0 10 	3.467e+19	8	28 	-1.183e+19	241	48 -2.284e+19	114	28 26 0 0 USGS 2@-nd@-
EOF

cat << EOF > focal_mechanisms1.dat
4 0 20 -3.16 0.42 2.74 1.23 -1.55 -1.23 26 X Y GCMT 1@-st@-
6 0 33 -0.38 2.21 -1.83 2.11 0.14 -0.81 26 X Y GCMT 2@-nd@-
EOF
cat << EOF > focal_mechanisms2.dat
8 0 20 -3.2498 0.7191 2.5308 1.305 0.2523 -1.6091 26 X Y AutoBATS 1@-st@-
10 0 20  -2.0849 2.3926 -0.3078 0.4014 0.013 -0.3395 26 X Y AutoBATS 2@-nd@-
EOF


gmt begin outputPDF/focal_mechanisms pdf A+m0.5c
    gmt set FORMAT_GEO_MAP ddd.x

    # Set the region and projection
    # The region is set to cover all six mechanisms plus some padding
    gmt basemap -R-1/11/-1/1 -JX12c/2c -B+n

    # Plot the focal mechanisms using -Sm
    gmt meca focal_mechanisms0.dat -Sx0.38c  -T -W0.5p -N  -G#0099FF
    #gmt meca focal_mechanisms0_p.dat -Sc0.38c -T2  -W0.5p -N  -G#0099FF
    gmt meca focal_mechanisms1.dat -Sm1c -Gred -W0.5p -N -T
    gmt meca focal_mechanisms2.dat -Sm1c  -W0.5p -N -T -G#009900
    # Add a title
    echo 6 1.2 "Six Sample Full Moment Tensor Focal Mechanisms" | gmt text -F+f12p,Helvetica-Bold+jBC -D0/0.5c -N
gmt end show

# Clean up the temporary data file
rm focal_mechanisms[012].dat
