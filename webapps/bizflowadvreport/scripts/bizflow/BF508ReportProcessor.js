(function (window) {

    var BF508ReportProcessor = function() {
		var LOG_ID = "[BF508ReportProcessor] ";
		var RECURSION_INTERVAL = 3000;
		var MAX_RECURSION_COUNT = 10000000;
		var rootContainerId = "reportContainer";
		var initialized = false;
		var recursion_count = 0;
		var reportTables = new Object();
		var browserType = "";
		var debugLogEnabled = false;

		console.log(LOG_ID + " file is loaded.");

		//---------------------------------------------------------------------
		// Main Workflow Logic
		//---------------------------------------------------------------------

		//--------------------
		// Runner - Main Scheduler
		function start() {
			logMessage("started (" + (recursion_count + 1) + ")");
			
			scanReportTables(rootContainerId);

			jQuery("body").removeAttr("role");
			
			if (jQuery("#" + rootContainerId + " table.jrPage[_bf508status]" ).length > 0) {
				processAll(rootContainerId);
			}
			
			setTimeout(function(){
				recursion_count++;
				if (recursion_count < MAX_RECURSION_COUNT) {
					window.BF508ReportProcessor.start(); 
				}
			}, RECURSION_INTERVAL);			
		}

		//--------------------
		// Processor - Bath
		function processAll(rootId) {
			logMessage("processing all registered tables.");
			
			jQuery("#" + rootId + " table.jrPage[_bf508status]" ).each(function( index ) {
				var _bf508status = jQuery(this).attr("_bf508status");
				var tableId = jQuery(this).attr("id");
				if (_bf508status === "marked") {
					process(tableId);
				} else {
					if (jQuery("#" + tableId + "[role='application']").length > 0) {
						remove508Blockers(tableId);
					}					
				}
				
			});
		}

		//--------------------
		// Processor - Individual		
		function process(tableId) {

			logMessage("processing " + tableId, "color:green;");

			//register table info
			registerReportTable(tableId, false, false);
			
			//initialize the table
			if (rootContainerId == "reportContainer") {
				if (!isTableInitialized(tableId)) {
					initReportViewer();
				}
			}
			
			//remove 508 blockers
			remove508Blockers(tableId);
			jQuery(window).trigger('resize');

			//remove empty rows from the table
			trimEmptyRows(tableId);
			
			addTableMetaInfo(tableId);

			//trimDuplicateReportCaptionSummary(tableId);
			
			//populateTableHeader(tableId);
			
			setReportClickable(tableId);

			setReportHeadMargin("10px");		

			//mark the table as processed
			jQuery("#" + tableId).attr("_bf508status", "processed");
		}

		function addTableMetaInfo(tableId) {
				//add table caption from table contents
				var tblCaption;
				if (rootContainerId == "reportContainer") {
					if (typeof reportTables.tableCaption === "undefined") {
						tblCaption = getReportCaption(tableId);
					} else {
						tblCaption = reportTables.tableCaption;
					}
				} else {
					tblCaption = getReportCaption(tableId)
				}

				if (typeof tblCaption !== "undefined") {
					reportTables.tableCaption = tblCaption;
					addTableCaption(tableId, tblCaption);
				}

				//add page navigation info
				var pageNaviInfo = getCurrentPageNaviInfo();

				//add table summary attribute from table contents
				var tblSummary;
				if (rootContainerId == "reportContainer") {
					if (typeof reportTables.tableSummary === "undefined") {
						tblSummary = getReportSummmary(tableId);
					} else {
						tblSummary = reportTables.tableSummary;
					}
				} else {
					tblSummary = getReportSummmary(tableId);
				}
				if (typeof tblSummary !== "undefined") {
					reportTables.tableSummary = tblSummary;
					addTableSummary(tableId, tblSummary + " " + pageNaviInfo);
				}

		}


		//---------------------------------------------------------------------
		// Report Content Modifier
		//---------------------------------------------------------------------
		function initReportViewer() {
			logMessage("initializing section 508 in the report");
			
			if ("y" == _bf508Enbabled || "yes" == _bf508Enbabled) {
				jQuery("#dataRefreshButton_508").show();
				
				logMessage("hiding report zoom toolbar buttons");
				jQuery("#viewerToolbar").css("margin", "5px");
				jQuery("#viewerToolbar.toolbar ul.buttonSet").hide();
				jQuery("#dataRefreshButton").hide();
				jQuery("#pagination").hide();
				jQuery("#viewerToolbar #reportZoom").hide();
				jQuery("#viewerToolbar #reportSearch").hide();
				
				jQuery("#pagination #page_first").attr('aria-label', 'move to the first page');
				jQuery("#pagination #page_prev").attr('aria-label', 'move to the previous page');
				jQuery("#pagination #page_next").attr('aria-label', 'move to the next page');
				jQuery("#pagination #page_last").attr('aria-label', 'move to the last page');
				jQuery("#pagination #page_current").attr('aria-label', 'current report page number');
				
				//Page Navigation
				generatePageNavigation();

				generateToolbarButtons();
				
				jQuery("#viewerToolbar .bfToolbarItems").focus(function(){
					jQuery(this).css("font-weight", "bold");
					});

				jQuery("#viewerToolbar .bfToolbarItems").focusout(function(){
					jQuery(this).css("font-weight", "normal");
					});
										
				removeApplicationMode("pagination");
			}
		}

		function generatePageNavigation() {
			var lastPageIndex = Report.lastPageIndex;

			if (lastPageIndex > 0) {
				if (jQuery("#viewerToolbar.toolbar #pageNavigationAction").length == 0) {
					jQuery("#viewerToolbar.toolbar").append(
						"<span style='margin-left:10px;'>"
						+ "<label for='pageNavigationAction'>Page Navigation</label>&nbsp;&nbsp;"
						+ "<select id='pageNavigationAction' "
						+ " class='bfToolbarItems' "
						+ " style='height:30px;width:200px' onchange='window.BF508ReportProcessor.goToPage(this)' "
						+ " aria-label='Page navigation dropdown list. to expand list use space key, to change selection arrow key'></select>"
						+ "</span>"
					);

					if (jQuery("#viewerToolbar.toolbar #pageNavigationAction").length > 0) {
						var mySelect = jQuery("#viewerToolbar.toolbar #pageNavigationAction");
						for (var i=0; i<lastPageIndex; i++) {
							var myOption = mySelect.append(
								jQuery('<option></option>').val(i).html("Go to page " + (i+1) + " of " + lastPageIndex + " in the report")
							);
							var x = 1;
						}
					}					
				}

			}	
		}

		function generateToolbarButtons() {
			//Toolbar button - Refersh
			if (jQuery("#dataRefreshButton_508").length == 0) {
				var reportTitle = jQuery("#reportViewFrame div.title").text();
				if (reportTitle == null) reportTitle = "";
				reportTitle = reportTitle.trim();
				var reportUpdatedDTime = ""; //jQuery("#dataTimestampMessage").text();
				
				jQuery("#viewerToolbar.toolbar").append(
					'&nbsp;&nbsp;&nbsp;<span style="display:;"><button id="dataRefreshButton_508" '
					+ ' class="bfToolbarItems" '						
					+ ' style="width:100px;height:30px;font-weight:normal;"'
					+ ' tabindex="0" '
					+ ' aria-label="Refresh ' + reportTitle + ' with latest data ' + reportUpdatedDTime + '"' 
					+ ' onclick="window.BF508ReportProcessor.refreshCurrentReport()">'
					+ 'Refresh</button>'
					+ ' </span>');
			}

			//Toolbar button - Export PDF
			if (jQuery("#Export_PDF").length == 0) {
				jQuery("#viewerToolbar.toolbar").append(
					'<span style="display:;"><button id="Export_PDF"'
						+ ' class="bfToolbarItems" '
						+ ' style="width:150px;height:30px;font-weight:normal;"'
						+ ' tabindex="0" '
						+ ' aria-label="Export the report to a PDF file"'
						+ ' onclick="window.BF508ReportProcessor.exportReport(\'pdf\');">'
						+ ' Export PDF</button>'
					+ ' </span>');
			}

			//Toolbar button - Export EXCEL
			if (jQuery("#Export_EXCEL").length == 0) {
				jQuery("#viewerToolbar.toolbar").append(
					'<span style="display:;"><button id="Export_EXCEL"'
						+ ' class="bfToolbarItems" '				
						+ ' style="width:100px;height:30px;font-weight:normal;"'
						+ ' aria-label="Export the report to an excel file"'
						+ ' onclick="window.BF508ReportProcessor.exportReport(\'xlsx\');">'
						+ ' Export Excel</button>'
					+ ' </span>');
			}

			//Toolbar button - Option
			if (jQuery("#ICDialog_508").length == 0) {
				jQuery("#viewerToolbar.toolbar").append(
					'<span style="display:;"><button id="ICDialog_508"'
						+ ' class="bfToolbarItems" '						
						+ ' style="width:150px;height:30px;font-weight:normal;"'
						+ ' tabindex="0" '
						+ ' aria-label="Open Input Controls Dialog"'
						+ ' onclick="window.BF508ReportProcessor.showReportOption();">'
						+ 'Input Controls</button>'
					+ ' </span>');
			}
		}

		function remove508Blockers(tableId) {
			//------------------------------
			//Removing ARIA attributes which prevent screen reader software from recognizing HTML tables in a report.
			//
			//	The application role indicates to assistive technologies 
			//	that an element and all of its children should be treated similar to a desktop application
			//	, and no traditional HTML interpretation techniques should be used. 
			//	This role should only be used to define very dynamic and desktop-like web applications.		
			//------------------------------
			logMessage("removing role attribute tableId=" + tableId, "color:blue;");
			jQuery("#" + tableId).removeAttr("role");
			jQuery("#" + tableId).removeAttr("aria-label");
			jQuery("#" + tableId).attr("role", "table");	

			//remove new line <BR> tag so that Jaws does not stop reading content of the cell at new line <BR> tag.
			jQuery("#" + tableId + " td[role='gridcell'] br").remove();
			jQuery("#" + tableId).css("width", "auto");

			//remove new line <BR> tag so that Jaws does not stop reading content of the cell at new line <BR> tag.
			jQuery("#" + tableId + " td span br").remove();	

		}

		function removeApplicationMode(elementId, mode) {
			if (typeof mode === "undefined" || mode == null) {
				jQuery("#" + elementId).removeAttr("role");
			} else {
				jQuery("#" + elementId).attr("role", mode);
			}
		}

		function trimEmptyRows(tableId) {

			//------------------------------
			//Trimming empty rows from tables
			//------------------------------
			logMessage("removing empty rows from tables for screen reader software to read and naviagte tables easily. tableId=" + tableId);
			jQuery("#" + tableId + " tr[style] td[colspan]" ).each(function( index ) {
				if ((jQuery( this ).text() == "\n" || jQuery( this ).text() == "\r" || jQuery( this ).text() == "") && jQuery( this ).siblings().length == 0) {
					logMessage(">>" + index + ": " + jQuery( this ).prop("tagName") + '=' + jQuery( this ).text() + ". siblings=" + jQuery( this ).siblings().length);
					if (index >= 0) {
						jQuery( this ).parent().remove();
					}
				}
			});
			
			jQuery("#" + tableId + " tr[style] td" ).each(function( index ) {
				if ((jQuery( this ).text() == "\n" || jQuery( this ).text() == "\r" || jQuery( this ).text() == "") && jQuery( this ).siblings().length == 0) {
					logMessage(">>" + index + ": " + jQuery( this ).prop("tagName") + '=' + jQuery( this ).text() + ". siblings=" + jQuery( this ).siblings().length);
					if (index >= 0) {
						jQuery( this ).parent().remove();
					}
				}
			});

			jQuery("#" + tableId + " tr[style='height:0']").remove(); 

			//for IE
			jQuery("#" + tableId + " tr[style]" ).each(function( index ) {
				var height = jQuery( this ).css('height');
				if (height == "0px" || height == "0" || height == "1") {
					jQuery( this ).remove();
				}
			});

			//for IE
			var find = '\n';
			var re = new RegExp(find, 'g');
			jQuery("#" + tableId + " tr[style]" ).each(function( index ) {
				var text = jQuery( this ).text();
				text = text.replace(re, "");
				if (text == "") {
					jQuery( this ).remove();
				}
			});

			/*
			jQuery("#" + tableId + " td[role='gridcell']").filter(function(index) {
				return (jQuery( this ).text() == "\n" || jQuery( this ).text() == "\r");
			}).remove();
			*/
			
		}

		//--------------------
		//Adding report summary
		function addTableSummary(tableId, summary) {

			logMessage("adding a table summary. " + summary);
			jQuery("#" + tableId + ":first").attr("summary", summary);
		}

		//--------------------
		//Adding caption to a reqport table
		function addTableCaption(tableId, caption) {
			logMessage("adding a table caption. " + caption);
			if (jQuery("#" + tableId + " caption").length == 0) {
				jQuery("<caption style='color:white;font-size:3px;height:2px;display:'>" + caption + "</caption>").prependTo("#" + tableId);
			}
		}
		
		function populateTableHeader(tableId) {
			jQuery("#" + tableId + " td[style]").each(function(index) {
				//jQuery(this).css("background-color")
			  //jQuery(this).replaceWith('<th>' + jQuery(this).text() + '</th>'); 
			});
		}

		function setReportHeadMargin(height) {
			if (jQuery("#_508headroom").length == 0) {
				logMessage("adding head room");
				jQuery( "<DIV id='_508headroom' style='height:" + height + ";' role='application'></DIV>" ).prependTo("#reportContainer");
			}
		}

		//--------------------
		//Removing first two rows - they are report caption and summary per CMS report templates
		function trimDuplicateReportCaptionSummary(tableId) {
			if (rootContainerId === "reportContainer") {
				jQuery("#" + tableId + " tr[role='row']:first").remove(); 
				jQuery("#" + tableId + " tr[role='row']:first").remove(); 
			} else {
				jQuery("#" + tableId + " tr:first").remove(); 
				jQuery("#" + tableId + " tr:first").remove(); 
			}
		}		

		//---------------------------------------------------------------------
		// Report Content Parser for predefined report format
		function getReportCaption(tableId) {
			var caption = "";
			var objTable = reportTables[tableId];
			if (objTable != null && typeof objTable !== "undefined") {
				caption = objTable.tableCaption;
			}
			if (null == caption || caption === "" || typeof caption === "undefined") {
				if (rootContainerId == "reportContainer") {
					caption = jQuery("#" + tableId + " tr[role='row'] td[role='gridcell'] span:first").text();
				} else {
					caption = jQuery("#" + tableId + " tr td span:first").text();
				}
			}
			return caption;
		}
		
		function getReportSummmary(tableId) {
			var summary = "";
			var objTable = reportTables[tableId];
			if (objTable != null && typeof objTable !== "undefined") {
				summary = objTable.tableSummary;
			}
			if (null == summary || summary === "" || typeof summary === "undefined") {
				if (rootContainerId == "reportContainer") {
					summary = jQuery("#" + tableId + " tr[role='row']:nth-child(2)").text();
				} else {
					summary = jQuery("#" + tableId + " tr:nth-child(2)").text();
				}
			}
			if (null != summary && typeof summary !== "undefined") {
				summary = summary.trim();
			}
			return summary;		
		}

		function getCurrentPageNaviInfo() {
			var pageInfo = "";
			try {
				var pageIndex = 1 +  Report.pageIndex;
				var lastPageIndex = 1 + Report.lastPageIndex;
				if (lastPageIndex > 1) {
					pageInfo = "Page " + pageIndex + " of total " + lastPageIndex;
				}
			} catch (e) {
				pageInfo = "";
			}
			return pageInfo;
		}

		//---------------------------------------------------------------------
		// Report Native Viewer Action Handler
		//---------------------------------------------------------------------

		//--------------------
		function refreshCurrentReport() {
			//refresh report
			viewer.jive && viewer.jive.hide();
			if ((typeof Controls !== "undefined")) {
				var selectedData = Controls.viewModel.get('selection');
				var controlsUri = ControlsBase.buildSelectedDataUri(selectedData);
				Report.refreshReport({freshData: true}, null, controlsUri ? '&' + controlsUri : '');
			} else {
				Report.refreshReport({freshData: true}, null, '');
			}
		}

		//--------------------
		function goToPage() {
			if(viewer.jive) viewer.jive.hide();
			var pageIndex = jQuery("#viewerToolbar.toolbar #pageNavigationAction").val();
            viewer.reportInstance.gotoPage(pageIndex);
		}
		

		//--------------------
		function showReportOption() {
            if (Controls.controlDialog){
                Controls.controlDialog.show();
            }				
		}
		
		//--------------------
		function exportReport(fileFormat) {
			if (fileFormat == null) fileFormat = "";
			var reportUnitURI = Report.reportUnitURI;
			var idx = reportUnitURI.lastIndexOf("/");
			reportUnitURI = reportUnitURI.substr(idx);
			reportUnitURI = "/bizflowadvreport/flow.html/flowFile/" + reportUnitURI + "." + fileFormat;
			logMessage("exporting [" + fileFormat + "] " + reportUnitURI);
			//alert("We are currently implementing " + reportUnitURI  + " export feature in accessibility mode.");
			Report.exportReport(fileFormat, reportUnitURI)
		}

		//---------------------------------------------------------------------
		// Table Processor Ulitity Functions
		//---------------------------------------------------------------------
		
		//--------------------
		// Logger - web browser console log
		function logMessage(message, style) {
			if (debugLogEnabled) {
				if (typeof style !== "undefined") {
					if (browserType !== "IE") {
						console.log("%c" + LOG_ID + message, style);
					} else {
						console.log(LOG_ID + message);
					}
				} else {
					console.log(LOG_ID + message);
				}
			}			
		}

		//--------------------
		// Scanner - finding target tables
		//	Report table is dynamically changed to a new table 
		//	when to navigate page by clicking on the page navigation toolbar button.
		//	therefore, we need to scan tables again.
		function scanReportTables(rootId) {
			logMessage("scanning report tables under!!! #" + rootId);
			//finding tables that the 508 processor has not found.
			jQuery("#" + rootId + " table.jrPage:not([id])" ).each(function( index ) {				
				//set ID if no ID exists
				var tableId = jQuery( this ).attr("id");
				if (typeof tableId === "undefined") {
					tableId = "_bftable_" + Math.floor(Math.random() * 1000000000);
					
					jQuery(this).attr("id", tableId);
					var tableContent = jQuery(this).text()
					//Do not process Disclaimer sections
					if ((tableContent.indexOf("Disclaimer") < 0) 
							&& (jQuery("#" + tableId + " tr").length > 2 )
							&& (jQuery("#" + tableId + " img").length <= 0)){
						jQuery(this).attr("_bf508status", "marked");
					}
				}
			});			
		}

		//--------------------
		// Register - Pulling Tabling Information from the scanned target tables
		function registerReportTable(tableId, isDashlet, isInitialized) {
			logMessage("regitering a table [" + tableId + "]");
			var tableInfo = reportTables[tableId];
			if (null == tableInfo || typeof tableInfo == "undefined") {
				tableInfo = {};
				tableInfo.tableId = tableId;
				tableInfo.isDashlet = isDashlet;
				tableInfo.initialized = isInitialized;	
				reportTables[tableId] = tableInfo;				
			}
			logMessage(JSON.stringify(tableInfo));	
		}

		//--------------------
		// Checking if the table has been initialized
		function isTableInitialized(tableId) {
			var tbl = reportTables[tableId];
			var initialized = false;
			try {
				if (tbl != null) {
				
					if (typeof tbl.initialized === "boolean") {
						initialized = tbl.initialized;
					}
				}
			} catch (e) {
				logMessage(e, "color:red;");
			} finally {
				logMessage("initialized="+ initialized);
			}
			return initialized;
		}
		
		function setReportClickable(tableId) {
			logMessage("making the report clickable.");
			jQuery("#" + tableId).removeAttr("tabindex");
		}
		
		function setTabindices(tableId) {
			logMessage("adding tabindex to span");
			jQuery("#" + tableId + " span:not(:empty)" ).each(function( index ) {
				jQuery( this ).attr("tabindex", "0");
			});
		}

		//---------------------------------------------------------------------
		// Getter and Setter
		function getRootContainer() {
			return rootContainerId;
		}

		function setRootContainer(rootId) {
			rootContainerId = rootId;
		}
		
		function getBrowserType() {
			return browserType;
		}
		
		function setBrowserType(browserTP) {
			browserType = browserTP;
		}

		function getDebugLogEnabled() {
			return debugLogEnabled;
		}
		
		function setDebugLogEnabled(enabled) {
			debugLogEnabled = enabled;
		}

		
		//---------------------------------------------------------------------
		// Interface		
        return {
			start: start
			, logMessage: logMessage
			//Report Action Handlers
			, refreshCurrentReport: refreshCurrentReport
			, showReportOption: showReportOption
			, exportReport: exportReport
			, goToPage: goToPage			
			//Getter and Setter
			, getRootContainer: getRootContainer
			, setRootContainer: setRootContainer
			, getBrowserType: getBrowserType
			, setBrowserType: setBrowserType
			, getDebugLogEnabled: getDebugLogEnabled
			, setDebugLogEnabled: setDebugLogEnabled
        }
    }

    var _initializer = window.BF508ReportProcessor || (window.BF508ReportProcessor = BF508ReportProcessor());
})(window);

