/* To force the length of textarea within 150 char */
function imposeMaxLength(Object, MaxLen){
	return (Object.value.length <= MaxLen);
} //end-imposeMaxLength()


/* To force the user enter only number */
function allowNum(fieldName){
	if((event.keyCode < 48)||(event.keyCode > 57)){
		alert("Please enter only number for "+fieldName);
		event.returnValue = false;
	} //end-if
} //end-allowNum()


/* To force the user enter only alphanumeric char */
function allowAlphaNumeric(fieldName){
	if((event.keyCode < 48)||(event.keyCode > 122)||((event.keyCode > 57)&&(event.keyCode < 65))||((event.keyCode > 90)&&(event.keyCode < 97))){
		alert("Please enter only alphanumeric character for "+fieldName);
		event.returnValue = false;
	} //end-if
} //end-allowNum()


/* To force the user enter only alphabet and space */
function allowAlphaNumericSpace(fieldName){
	if((event.keyCode < 32)||(event.keyCode > 122)||((event.keyCode > 57)&&(event.keyCode < 65))||((event.keyCode > 90)&&(event.keyCode < 97))||((event.keyCode > 32)&&(event.keyCode < 48))){
		alert("Please enter only alphanumeric character or space for "+fieldName);
		event.returnValue = false;
	} //end-if
} //end-allowNum()


/* To force the user enter only alphanumeric char and dash=45 */
function allowAlphaNumericDash(fieldName){
	if((event.keyCode < 45)||(event.keyCode > 122)||((event.keyCode > 57)&&(event.keyCode < 65))||((event.keyCode > 90)&&(event.keyCode < 97))||((event.keyCode > 45)&&(event.keyCode < 48))){
		alert("Please enter only alphanumeric character or dash for "+fieldName);
		event.returnValue = false;
	} //end-if
} //end-allowAlphaNumericDash()


/* Strip leading and trailing space of the textControl passed in */
function stripSpaces(textControl){
	x = textControl.value;
	while (x.substring(0,1) == ' ') x = x.substring(1);
	while (x.substring(x.length-1,x.length) == ' ') x = x.substring(0,x.length-1);
	textControl.value = x;
} //end-stripSpaces()


/* Validate on email field */
function emailValidator(fieldName){
	var emailControl = document.getElementById(fieldName);
	
	/* Check if Email is null */
	/*if(emailControl.value.length==0){
		alert("Please enter an Email address.");
		emailControl.focus();
		return false;
	}else{*/
	if(emailControl.value.length>0){
		/* Check if Email is of valid form */
		var validEmail = /^.+@.+\..{2,}$/;
		if(!validEmail.test(emailControl.value)){
			alert("Please enter a valid Email address.");
			emailControl.value = '';
			emailControl.focus();
			return false;
		} //end-if
	} //end-if-else
} //end-emailValidator()


/* To move items to/from between 2 DDM Controls */
function moveItem(ctrlSource, ctrlTarget){		
	var Source = document.getElementById(ctrlSource);
   	var Target = document.getElementById(ctrlTarget);

	if ((Source != null) && (Target != null)){
		for(var i=Source.options.length-1;i>=0;i--) {		
			if(Source.options[i].selected){
				var newOption = new Option(); // Create a new instance of ListItem
				newOption.text = Source.options[Source.options.selectedIndex].text;
				newOption.value = Source.options[Source.options.selectedIndex].value;
			
				Target.options[Target.length] = newOption; //Append the item in Target
				Source.remove(Source.options.selectedIndex);  //Remove the item from Source
			} //end-if
		} //-for
	} //end-if
} //end-moveItem()

	
/* To move items in a DDM Controls up/down */
function moveUpDown(moveDir, moveDDMTarget){		
	var moveDDMControl = document.getElementById(moveDDMTarget);
    			
	if (moveDDMControl.length > 0){
		if(moveDir == "Up"){
			// Move selected item up by 1 position except the 1st item
			for(var j=1; j<moveDDMControl.options.length; j++) {
				if(moveDDMControl.options[j].selected){
					// Swap the position of current selected item with the item preceding it
					swapToMove(j, j-1, moveDDMControl);
				} //end-if
			} //-for
		} //end-if

		if(moveDir == "Down"){
			// Move selected item down by 1 position except the last item
			for(var k=moveDDMControl.options.length-2; k>=0; k--) {
				if(moveDDMControl.options[k].selected){
					// Swap the position of current selected item with the item after it
					swapToMove(k, k+1, moveDDMControl);
				} //end-if
			} //-for
		} //end-if
	}else{
		alert("No item available for moving up/down.");
	} //end-if-else
} //end-moveUpDown()


/* To swap the 2 items' index to move them up/down */
function swapToMove(srcIndex, targetIndex, moveDDMControl){
	var tempOption = new Option();

	// Swap the position of srcIndex item with targetIndex Item
	tempOption.text = moveDDMControl.options[targetIndex].text;
	tempOption.value = moveDDMControl.options[targetIndex].value;
    moveDDMControl.options[targetIndex].text = moveDDMControl.options[srcIndex].text;
	moveDDMControl.options[targetIndex].value = moveDDMControl.options[srcIndex].value;
    moveDDMControl.options[srcIndex].text = tempOption.text;
	moveDDMControl.options[srcIndex].value = tempOption.value;

	// Adjust item's "selected" status after change position
	moveDDMControl.options[srcIndex].selected = false;
	moveDDMControl.options[targetIndex].selected = true;
}


function showOpener(){
	//window.opener.document.location.reload();

	if (window.opener) {	//if opener exist
		//Close current window and show parent window without refreshing
		if(!window.opener.closed){
			window.opener.document.focus();
		}
		self.close();
	}else{		//if load on same window (no opener), redirect back to Home page if "main" btn is click
		window.location.replace("/tps/welcome");
	} //end-if-else
}

/************* Following Functions also involved in AJAX Section *****************/
/* To remove all DDM items */
function removeAllDDMItem(DDMName){
	var DDMControl = document.getElementById(DDMName);
	if(DDMControl.options.length > 0){
		for(var n=(DDMControl.options.length-1); n>=0; n--){
			// delete all options in the drop down list
			DDMControl.remove(n); 
		} //end-for
	} //end-if
} //end-removeAllDDMItem()


function stripASCIIControlChar(text){
	x = text;
	while ((x.charCodeAt(0) >= 0)&&(x.charCodeAt(0) <= 31)) {x = x.substring(1);}
	while ((x.charCodeAt(x.length-1) >= 0)&&(x.charCodeAt(x.length-1) <= 31)) x = x.substring(0,x.length-1);
	while (x.substring(0,1) == ' ') x = x.substring(1);
	while (x.substring(x.length-1,x.length) == ' ') x = x.substring(0,x.length-1);
	return x;
} //end-stripSpaces()


function filterRemoveDDMItem(removeItemControl, guidingCheckControl){
	/* Filter thru all removeItemControl(availSubjectDDM/availVenueDDM) options against guidingCheckControl
	(subjectAssignedDDM/inListDDMControl/chosenVenueDDM) options */
	if(guidingCheckControl.options.length > 0){											
		for(var y=0; y<guidingCheckControl.options.length; y++){
			for(var z=0; z<removeItemControl.options.length; z++){
				/* Remove the option from removeItemControl if duplicate in guidingCheckControl */
				if(guidingCheckControl.options[y].value == removeItemControl.options[z].value){
					removeItemControl.remove(z);
					break;
				} //end-if
			} //end-for-z
		} //end-for-y
	} //end-if
} //end-filterRemoveDDMItem()						
