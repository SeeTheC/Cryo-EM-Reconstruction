# run: awk  -v micrograph="14sep05c_00024sq_00003hl_00002es_particles" -f getCoorrdinate.awk run1_shiny_mp007_data_dotstar.txt.csv 
BEGIN {FS=" ";i=0;l=0;x[l]=0;y[l]=0; print(micrograph)}
{ 		
	i++;
	if (NF > 14 )
	{
		if(index($10, micrograph) != 0)
		{
			printf("%s\t%d\t%d\n",$10,$11,$12);
			l++;	
			x[l]=$11;
			y[l]=$12;
		}			
	}
}
END {
	
	printf("X:\n");
	printf("[");  
	for (k = 1; k <= l; k++)
	    printf("%d,",x[k])
	printf("]\n");
	printf("Y:\n");
	printf("[");  
	for (k = 1; k <= l; k++)
	    printf("%d,",y[k])
	printf("]\n");  
}

