#awk  -v micrograph="14sep05c_00024sq_00003hl_00002es_particles" -f getCoorrdinate.awk run1_shiny_mp007_data_dotstar.txt.csv 
awk  -v micrograph="$1" -f getCoorrdinate.awk "$2" > result.csv
