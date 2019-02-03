
# wcrp-voter-tables

## build load tables for zoho data# base

### base table

   base	Abbr	            12	string
   base	affidavit	        12	string
   base	apartment_number	12	string
   base	birth_date      	10	date
   base	birth_place	        5	string
   base	building_number 	4	string
   base	city	            25	string
   base	drivers_license	    16	string
   base	gender	            1	char
   base	house_fraction	    3	string
   base	house_number	    10	string
   base	image_id	         9	bin
   base	language	        5	string  
   base	last_voted	        1	string
   base	military	        1	char
   base	name_first      	16	string
   base	name_last	        32	string
   base	name_middle	        16	string
   base	name_prefix	        5	string
   base	name_suffix	        5	string
   base	post_dir	        5	string
   base	pre_dir	            5	string
   base	state	            2	string
   base	status          	1	char
   base	street	            24	string
   base	type	            5	char
   base	voter_id	        9	string
   base	zip	                10	string

### contact table

   contact	care_of	40	
   contact	email	16	phone
   contact	mail_city	40	
   contact	mail_country	16	
   contact	mail_state	2	
   contact	mail_street	40	
   contact	mail_zip	10	
   contact	phone	16	phone
   contact	phone_type	16	string
   donor	date_pledged		
   donor	date_remitted		
   donor	pledge_id		
   donor	pledged	7	numeric
   donor	remitted	7	numeric
   political	alpha_split	32	string
   political	consolidation	9	string
   political	party	5	string
   political	portion	3	string
   political	precinct	9	string
   political	precinct_name	24	string
   political	reg_date	10	date
   political	reg_date_original	10	date
   voting	vote_01	8	string
   voting	vote_02	8	string
   voting	vote_03	8	string
   voting	vote_04	8	string
   voting	vote_05	8	string
   voting	vote_06	8	string
   voting	vote_07	8	string
   voting	vote_08	8	string
   voting	vote_09	8	string
   voting	vote_10	8	string
   voting	vote_11	8	string
   voting	vote_12	8	string
   voting	vote_13	8	string
   voting	vote_14	8	string
   voting	vote_15	8	string
   voting	vote_16	8	string
   voting	vote_17	8	string
   voting	vote_18	8	string
   voting	vote_19	8	string
   voting	vote_20	8	string
			
   volunteer			
   officer			