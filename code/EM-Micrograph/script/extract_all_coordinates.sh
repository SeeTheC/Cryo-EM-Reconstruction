#awk  -f getCoorrdinate.awk run1_shiny_mp007_data_dotstar.txt.csv 
awk  -f getAllCoorrdinate_80Plasmodium.awk "$1" > result.csv
