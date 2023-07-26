/*
 * Macro: Background Subtraction
 * 
 * Copyright (c) 2023 Alyssa Bergmann Borges
 * 
 * ------------------------------------------
 * Permission Notice:
 * I hereby grant permission, free of charge, to any person to use, copy, modify, and merge this macro as long as the original source is cited:
 * Borges, A. (2023). The endo-lysosomal system of Trypanosoma brucei: insights from a protist cell model [Doctoral thesis, Julius-Maximilians-Universität Würzburg].
 * ------------------------------------------
 * 
 * Overview:
 * The purpose of this macro is to subtract the background of Z projections for further analysis (e.g., colocalization).
 * 
 * 
 * Note: 
 * At this stage, the macro will perform background subtraction and save the files, but it does not include additional analysis functionalities.
 *  
 *  
 * Functionalities:
 * 1- automatically open images from separate folders (ensure one folder per channel); 
 * 2- convert projections into 8bit;
 * 3- perform convoluted background subtraction on each projection;
 * 4- save projections (background subtracted) as .tif to be used in further analysis.
 * 
 * 
 * ------------------------- 
 * Instructions:
 * Name your output folder in: "analysisFolderName = [name]".
 * -------------------------
 *  
 *   
 */
 
 analysisFolderName = "Projections_BackgroundSubtracted";


//-------------- GUI ----------------//
Dialog.create("Analysis set up");
	Dialog.addDirectory("Input folder", "");
	Dialog.addDirectory("Far red channel folder", "");
	Dialog.addDirectory("Red channel folder", "");
	Dialog.addDirectory("Green channel folder", "");
	Dialog.addNumber("Start analysis by image (index)", 0);
Dialog.show();
	userChosenDirectory = Dialog.getString();
	channelA = Dialog.getString();
	channelB = Dialog.getString();
	channelC = Dialog.getString();
	b = Dialog.getNumber();	//allows you to chose from which image you want to start your analysis
	

//-------------- Setting working directory ----------------//
outputDirName = userChosenDirectory + analysisFolderName; //creates a folder to save your analysis
outputDirPath = outputDirName + File.separator; //creates a path to your folder
File.makeDirectory(outputDirName); //creates the output directory


//-------------- Opening images ----------------//
chAList = getFileList(channelA);
chBList = getFileList(channelB);
chCList = getFileList(channelC);

openingImages();
function openingImages() {
	
	//Channel A
	for(a=b; a<chAList.length; a++){
	if(endsWith(chAList[a],".tif")){
		open(channelA + chAList[a]);
		chA = getTitle();
	}
	
	//Channel B
	if(endsWith(chBList[a],".tif")){
		open(channelB + chBList[a]);
		chB = getTitle();
	}
	
	//Channel C
	if(endsWith(chCList[a],".tif")){
		open(channelC + chCList[a]);
		chC = getTitle();
	}
	
	subtractingBackground();
	
	}
}


//--------Subtracting background of projections---//	
function subtractingBackground() { 

	selectWindow(chA); 
	run("8-bit");
	temporaryFarRed = getTitle();
	run("Duplicate...", "title=[copy_" + chA + "]");
	dupliFarRed = getTitle();
	waitForUser("Action Required", "Please, place images side-by-side");
	selectWindow(dupliFarRed);
	run("Convoluted Background Subtraction"); 
	imageFarRed = getTitle();

	selectWindow(imageFarRed);
		saveAs("Tiff", outputDirPath + "BackgroundSubtracted_" + chA);
		
		
	selectWindow(chB); 
	run("8-bit");
	temporaryRed = getTitle();
	run("Duplicate...", "title=[copy_" + chB + "]");
	dupliRed = getTitle();
	waitForUser("Action Required", "Please, place images side-by-side");
	selectWindow(dupliRed);
	run("Convoluted Background Subtraction"); 
	imageRed = getTitle();

	selectWindow(imageRed);
		saveAs("Tiff", outputDirPath + "BackgroundSubtracted_" + chB);
		
	
	selectWindow(chC); 
	run("8-bit");
	temporaryGreen = getTitle();
	run("Duplicate...", "title=[copy_" + chC + "]");
	dupliGreen = getTitle();
	waitForUser("Action Required", "Please, place images side-by-side");
	selectWindow(dupliGreen);
	run("Convoluted Background Subtraction"); 
	imageGreen = getTitle();

	selectWindow(imageGreen);
		saveAs("Tiff", outputDirPath + "BackgroundSubtracted_" + chC);

		
close("*");
}