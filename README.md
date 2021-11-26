# TagsToTable a.k.a. TTT

Welcome to the last step of "UFC - BAP/HDF5Viwer - MergeTags - TTT" [Software Chain](https://github.com/UVA-CAMA/NICUHDF5Viewer/wiki).
- In short, the software chain calculates clinically meaningful information from NICU bedside monitoring data, including  unfavorable events during infants' respiratory trajectory, statistical moments of Vital signs or chest-impedience signals, etc. 
- The softwares are developed by Center for Advanced Medical Analytics (CAMA), school of Medicine, UVA. 

### How to use TTT
- download and intall TTT from [here](https://github.com/JiaxingQiu/TagsToTable/releases/tag/v1.0)
- put resultmerge.mat and logmerged.mat files of any cohort of your interest in one folder/directory, there files are generated by BAP and MergeTags;
- direct TTT to the cohort path with .mat files in the setup tab;
- specify a path where you want to save .csv files;
- run TTT to save table format daily, hourly, or every UTC second event result or statistic values to this destination directory;
- That's it, you will see the destination folder being pulled up (with the CSV files you want) each time TTT runs a task. 

![alt text](https://github.com/JiaxingQiu/TagsToTable/blob/main/resources/ttt_overview.png)
