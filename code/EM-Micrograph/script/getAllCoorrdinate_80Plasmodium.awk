# run: awk -f getAllCoorrdinate.awk ~/Projection/mtp-data/RealDataset/Apo-Ferritin/Particles_Marking/particle_data.star
BEGIN {FS=" ";i=0;l=0;x[l]=0;y[l]=0; print("name,x,y")}
{ 		
	i++;
	if (NF > 3 )
	{
			printf("%d,%d\n",$1,$2);
			l++;	
			x[l]=$11;
			y[l]=$12;			
	}
}
END {
 
}

