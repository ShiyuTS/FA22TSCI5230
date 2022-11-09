# import python libraries
import pandas as pd # Python: panda = R: dplyr
import numpy as np
import os # check for files and manipulate files
import requests
import zipfile
import pickle
from tqdm import tqdm 

# set the download url to  'https://physionet.org/static/published-projects/mimic-iv-demo/mimic-iv-clinical-database-demo-1.0.zip';
input_data = 'https://physionet.org/static/published-projects/mimic-iv-demo/mimic-iv-clinical-database-demo-1.0.zip'

# Create a data directory if it doesn't already exist (don't give an error if it does)
os.makedirs('data', exist_ok = True)

# Platform-independent code for specifying where the raw downloaded data will go
download_path = os.path.join('data', 'TempData.zip')


# Download the file from the location specified by the Input_Data variable
# as per https://stackoverflow.com/a/37573701/945039
request = requests.get(input_data, stream = True)
size_in_bytes = int(request.headers.get('content-length', 0))
block_size = 1024
progress_bar = tqdm(total = size_in_bytes, unit = 'iB', unit_scale = True) 

# create a loop: update progress bar, adds downloaded data to files that we specified
with open(download_path, 'wb') as file:
  for data in request.iter_content(block_size): # for every 1024 bites, block it and update progress bar
    progress_bar.update(len(data))
    file.write(data) # file has property of write, if put data in here, it writes the file
progress_bar.close()

# assert
assert progress_bar.n==int(size_in_bytes), 'download not finish'

to_unzip = zipfile.ZipFile(download_path)

# create a dictionary (~= list in R):dd ##dd['a'] = 'b'
dd = {}

# iterate over the zipped file to look for file names
# ii = to_unzip.namelist()[3] # a quick look into 3+1th file names under object: to_unzip
# ii is a character string: ii.endswith('csv.gz'): find files that end with 'csv.gz'
# os.path.split(ii): split the path and file name; os.path.split(ii)[1] obtain the second object
#replace(a, b): a: string to lookfor, b: what to replace with
# os.path.split(ii)[1].replace('.csv.gz','') ## equivalent to 'patient.csv.gz'.replace('.csv.gz','') 

for ii in to_unzip.namelist(): 
  if ii.endswith('csv.gz'): # the following lines will be run if the if statement is true
    dd[os.path.split(ii)[1].replace('.csv.gz','')] = pd.read_csv(to_unzip.open(ii), compression = 'gzip', low_memory = False)
    
dd.keys() # obtain names of all tables under dd 
  



"""
# Save the downloaded file to the data directory
# ... but the concise less readable way to do the same thing is:
# open(Zipped_Data, 'wb').write(requests.get(Input_data))
# Unzip and read the downloaded data into a dictionary named dd
    # full names of all files in the zip
    # look for only the files ending in csv.gz
    # when found, create names based on the stripped down file names and
    # assign to each one the corresponding data frame which will be uncompressed
    # as it is read. The low_memory argument is to avoid a warning about mixed data types
# Use pickle to save the processed data
"""
