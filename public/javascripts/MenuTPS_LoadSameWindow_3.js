/*
   Apycom DHTML Menu data file
   Created by Apycom DHTML Tuner
   http://dhtml-menu.com
*/


// --- DHTML Tuner style names ---
var itemStylesNames=["Individual Style","Individual Style",];
var menuStylesNames=[];
// --- End of DHTML Tuner style names ---

//------- Common -------
var isHorizontal = 1;
var saveNavigationPath = 1;
var showByClick = 0;
var bottomUp = 0;
var orientation = 1;
var columnPerSubmenu = "";
var pressedItem = -2;
var blankImage = "/Images/blank.gif";
var pathPrefix = "";
var statusString = "link";

//------- Menu -------
var menuWidth = "120";
var menuBorderWidth = 1;
var menuBorderStyle = "solid";
var menuBackImage = "";

//------- Menu Positioning -------
var absolutePos = 0;
var posX = 0; 	//20
var posY = 0;	//15
var floatable = 1;
var floatIterations = 0;
var movable = 0;

//------- Submenu Positioning -------
var topDX = 35;	//5
var topDY = 25;
var DX = 5;
var DY = 5;

//------- Font -------
var fontStyle = "bold 9pt Verdana";
var fontColor = ["#000000","#FFFFFF"];
var fontDecoration = ["none",""];

//------- Items -------
var itemBorderWidth = 1;
var itemBorderStyle = ["solid","solid"];
var itemBackImage = ["",""];
var itemAlign = "left";
var subMenuAlign = "left";
var itemSpacing = 1;
var itemPadding = 3;
var itemCursor = "";
var itemTarget = "_self";

//------- Colors -------
var menuBackColor = "#000000";
var menuBorderColor = "#0000A0";
var itemBackColor = ["#E2EEFF","#000000"];
var itemBorderColor = ["#C0E0FF","#FFFF00"];

//------- Icons -------
var iconTopWidth = 16;
var iconTopHeight = 16;
var iconWidth = 16;
var iconHeight = 16;
var arrowImageMain = ["/Images/arrow2.gif","/Images/arrowm1.gif"];
var arrowImageSub = ["/Images/arrow2.gif","/Images/arrowm1.gif"];
var arrowWidth = 12;
var arrowHeight = 12;

//------- Separators -------
var separatorWidth = "100%";
var separatorHeight = "5";
var separatorAlignment = "center";
var separatorVWidth = "10";
var separatorVHeight = "16";

//------- Visual Effects -------
var transparency = "100";
var transition = 6;
var transDuration = 300;
var transOptions = "";
var shadowLen = 0;
var shadowTop = 1;
var shadowColor = "#FFFFFF";

//------- CSS Mode -------
var cssStyle = 0;
var cssClass = "";

//------- MAC OS Additional -------
var macIEoffX = 10;
var macIEoffY = 15;
var macIEtopDX = 0;
var macIEtopDY = 2;
var macIEDX = -3;
var macIEDY = 0;

var itemStyles = [
    ["fontStyle=bold 7pt Verdana",],
    ["itemBackColor=#E2EEFF,#FFFFFF","itemBorderColor=#C0E0FF,#80A0FF",],
];

var menuItems = [
    ["Home","welcome",,, "Home Tip", "mainFrame", , , , , , ],
	["Subject Information","", ,, "Subject Information Tip", "mainFrame", , , , , , ],
	     ["|Subject","subject", ,,"Subject Tip", "mainFrame", , , , , , ],
	     ["|Venue","venue", ,, "Venue Tip", "mainFrame", , , , , , ],	   
	    ["|Staff","staff", ,, "Staff Tip", "mainFrame", , , , , , ],
	    ["|Subject List","subject_list",,, "Subject List Tip", "mainFrame", , , , , , ],
	    ["|Shared Group","shared_code",,, "Shared Group Tip", "mainFrame", , , , , , ],	    
	    ["|Reference Subject","ref_subject",,, "Reference Subjects", "mainFrame", , , , , , ],
	["Show Schedule","", ,, "Show Schedule Tip", "mainFrame", , , , , , ],
		["|By Subjects","by_subjects",,, "Scheduling Subject Tip", "mainFrame", , , , , , ],
		["|By Staffs","by_staffs", ,, "Scheduling Staff Tip", "mainFrame", , , , , , ],
		["|By Venues","by_venues", ,, "Venues Schedule Tip", "mainFrame", , , , , , ],
		["|By Groups","by_groups",,, "Groups Schedule Tip", "mainFrame", , , , , , ],
	
];

apy_init();