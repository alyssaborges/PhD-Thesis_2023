/*
 * Macro: Preparation of Composites from Deconvolved Images
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
 * The purpose of this macro is to prepare composites from deconvolved images.
 * 
 * 
 * Note: 
 * To use this macro, ensure you already have hyperstacks of channels saved as .tif in different folders (one folder per channel).
 * This macro is intended to be used for 5 channels (DIC, Far red, Red, Green, and Blue).
 *   
 *  
 * Functionalities:
 * 1- automatically open images from separate folders (ensure one folder per channel - ideally have deconvolved images); 
 * 2- prepare projections (Max Intensity) and adjust B&C;
 * 3- prepare composites: DIC (gray), Far red (magenta), Red (yellow), Green (cyan), and Blue (gray and magenta);
 * 4- save composites as .png.
 * 
 * 
 * ------------------------- 
 * Instructions:
 * Name your output folder in: "analysisFolderName = [name]".
 * Make sure your DIC images have a short name (this name will be used for the composites)
 * -------------------------
 *  
 *   
 */
 
 analysisFolderName = "Composites";


//-------------- GUI ----------------//
Dialog.create("Analysis set up");
	Dialog.addDirectory("Input folder", "");
	Dialog.addDirectory("DIC channel folder", "");
	Dialog.addDirectory("Far red channel folder", "");
	Dialog.addDirectory("Red channel folder", "");
	Dialog.addDirectory("Green channel folder", "");
	Dialog.addDirectory("DAPI channel folder", "");
	Dialog.addNumber("Start analysis by image (index)", 0);
Dialog.show();
	userChosenDirectory = Dialog.getString();
	channelDic = Dialog.getString();
	channelA = Dialog.getString();
	channelB = Dialog.getString();
	channelC = Dialog.getString();
	channelDapi = Dialog.getString();
	b = Dialog.getNumber();	//allows you to chose from which image you want to start your analysis
	
	
//-------------- Setting working directory ----------------//
outputDirName = userChosenDirectory + analysisFolderName; //creates a folder to save your analysis
outputDirPath = outputDirName + File.separator; //creates a path to your folder
File.makeDirectory(outputDirName); //creates the output directory


//-------------- Opening images ----------------//
chDicList = getFileList(channelDic);
chAList = getFileList(channelA);
chBList = getFileList(channelB);
chCList = getFileList(channelC);
chDapiList = getFileList(channelDapi);

openingImages();
function openingImages() {
	//DIC
	for(a=b; a<chDicList.length; a++){
	if(endsWith(chDicList[a],".tif")){
		open(channelDic + chDicList[a]);
		dicCh = getTitle();
		
	//Far red
	if(endsWith(chAList[a],".tif")){
		open(channelA + chAList[a]);
		farRedCh = getTitle();
	}
	
	//Red
	if(endsWith(chBList[a],".tif")){
		open(channelB + chBList[a]);
		redCh = getTitle();
	}
		
	//Green
	if(endsWith(chCList[a],".tif")){
		open(channelC + chCList[a]);
		greenCh = getTitle();
	}
	
	//Blue
	if(endsWith(chDapiList[a],".tif")){
		open(channelDapi + chDapiList[a]);
		blueCh = getTitle();
	}
		
		runProjections();
		
	}
	}
} 								

		
//-------------- Preparing projections ----------------//
function runProjections() {

	selectWindow(farRedCh);
	run("Z Project...", "projection=[Max Intensity]");
	run("Magenta"); run("In [+]"); run("In [+]");
	waitForUser("Adjust B&C and click OK");
	farRed = getTitle();
	
	selectWindow(redCh);
	run("Z Project...", "projection=[Max Intensity]");
	run("Yellow"); run("In [+]"); run("In [+]");
	waitForUser("Adjust B&C and click OK");
	red = getTitle();
	
	selectWindow(greenCh);
	run("Z Project...", "projection=[Max Intensity]");
	run("Cyan"); run("In [+]"); run("In [+]");
	waitForUser("Adjust B&C and click OK");
	green = getTitle();
	
	selectWindow(blueCh);
	numberSlices = nSlices;
	if (numberSlices != 1) {
		run("Z Project...", "projection=[Max Intensity]");
	}
	blueProjection1 = getTitle();
	run("Duplicate...", " ");
	blueProjection2 = getTitle();
	selectWindow(blueProjection1);
	run("Magenta");
	waitForUser("Adjust B&C and click OK");
	blue1 = getTitle();
	selectWindow(blueProjection2);
	run("Grays");
	waitForUser("Adjust B&C and click OK");
	blue2 = getTitle();
	
	runComposites();
	
}	


//-------------- Preparing composites ----------------//	

function runComposites() {
	
	run("Merge Channels...", "c4=[" + dicCh +"] c6=[" + blue1 +"] create keep");
	//run("In [+]"); run("In [+]");
	//waitForUser("Adjust B&C and apply, click OK");
	saveAs("PNG", outputDirPath + "Composite1_DIC-DAPI_" + dicCh);
	close();
	
	run("Merge Channels...", "c6=[" + farRed +"] c4=[" + blue2 +"] create keep");
	//run("In [+]"); run("In [+]");
	//waitForUser("Adjust B&C and apply, click OK");
	saveAs("PNG", outputDirPath + "Composite2_FarRed-DAPI_" + dicCh);
	close();
	
	run("Merge Channels...", "c7=[" + red +"] c4=[" + blue2 +"] create keep");
	//run("In [+]"); run("In [+]");
	//waitForUser("Adjust B&C and apply, click OK");
	saveAs("PNG", outputDirPath + "Composite3_Red-DAPI_" + dicCh);
	close();
		
	run("Merge Channels...", "c5=[" + green +"] c4=[" + blue2 +"] create keep");
	//run("In [+]"); run("In [+]");
	//waitForUser("Adjust B&C and apply, click OK");
	saveAs("PNG", outputDirPath + "Composite4_Green-DAPI_" + dicCh);
	close();
	
	run("Merge Channels...", "c6=[" + farRed +"] c7=[" + red +"] c5=[" + green +"] c4=[" + blue2 +"] create keep");
	//run("In [+]"); run("In [+]");
	//waitForUser("Adjust B&C and apply, click OK");
	saveAs("PNG", outputDirPath + "Composite5_FarRed-Red-Green-DAPI_" + dicCh);
	close();
	
	run("Merge Channels...", "c6=[" + farRed +"] c7=[" + red +"] c5=[" + green +"] create keep");
	//run("In [+]"); run("In [+]");
	//waitForUser("Adjust B&C and apply, click OK");
	saveAs("PNG", outputDirPath + "Composite6_FarRed-Red-Green_" + dicCh);
	close();
	
	run("Merge Channels...", "c4=[" + dicCh +"] c6=[" + farRed +"] create keep");
	//run("In [+]"); run("In [+]");
	//waitForUser("Adjust B&C and apply, click OK");
	saveAs("PNG", outputDirPath + "Composite7_DIC-FarRed_" + dicCh);
	close();
	
	run("Merge Channels...", "c4=[" + dicCh +"] c7=[" + red +"] create keep");
	//run("In [+]"); run("In [+]");
	//waitForUser("Adjust B&C and apply, click OK");
	saveAs("PNG", outputDirPath + "Composite8_DIC-Red_" + dicCh);
	close();
	
	run("Merge Channels...", "c4=[" + dicCh +"] c5=[" + green +"] create keep");
	//run("In [+]"); run("In [+]");
	//waitForUser("Adjust B&C and apply, click OK");
	saveAs("PNG", outputDirPath + "Composite9_DIC-Green_" + dicCh);
	close();

close("*");
}
