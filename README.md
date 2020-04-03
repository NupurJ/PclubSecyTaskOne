# PclubSecyTaskOne

## Question 1: Scraping
### Part 1:
Run file scrape.py to get a .csv file of the format Name,Organisation,Project.  
<code>python3 scrape.py \<url-of-webpage></code>  
Output: out.csv  

### Part 2:
Run script.sh to print list of non-official names and get a .csv file of the format Name,Roll_No,Branch,Organisation,Project.  
<code>./script.sh</code>  
Output: final.csv.  
script.sh uses the out.csv file obtained in the last part and the students.json (same as the file included in the mail) to produce its output

Very minor edit made at 1305: replace line 58 of script.sh with the following:  
<code>grep "$name" $beautjson | sed -n "s/^.*\"d\":\"\([A-Z a-z.]*\)\".*\"i\":\"\([0-9]*\)\",\"n\":\"$name\",.*/\2,\1,/p" >$tmp2</code>

