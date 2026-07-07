# Well-Plugging-Data-Science-
Here is a Data Science Pennsylvania Well Plugging Project created with the use of Python (Pandas, Numpy, Sci-kit, Matplotlib), MySQL, AI for research, and Excel.
RidgeCV Model is intended to predict the actual amount of days a project will take designed to optimize direct contract and turnkey project. Well plugging project dates can never be accurately predicted due to the 'noise' that can occur when you are on the field. That includes weather, missing tools, and anything in between. That is why this model uses implemented field 'noise' to simulate how long a project will take based on engineered features created by the well type and well status. This model reached a Mean Absolute Error of 0.97 and a R2 score of 89%. 
K-Cluster Model is designed to group the wells in 7 counties in the Pennsylvania Appalachin Basin area. This was built on the idea to optimize truck logistics in order for teams to be more efficient in machinery transportation as machinery is expensive to transport from well to well. With this clustering we can identify the main areas where lots of wells are located and work upon those. 
How to run this:
1.Export from SQL: Run your query on the database abandonedwellspa.abandoned_orphan_web and export the resulting data table as an Excel spreadsheet (.xlsx) or a CSV file.
2.Save the File: Move that exported data file into the exact same folder on your computer where this Jupyter Notebook is saved.
3.Link to Python: Open the notebook, make sure the data_path variable matches your filename, and run the cells to load the data into pandas
Also, make sure you're running an .xlsx if using an excel file and .csv for csv files
