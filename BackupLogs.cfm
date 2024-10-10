<cfscript>
    import ioffice.pdfs.PDFDirectory;
    try {
        if( !URL.keyExists("id")
            || QueryExecute(
                "SELECT 1 FROM configBatchID WHERE systemValue = :id;",
                {id: {cfsqltype: "nvarchar", value: URL.id}}
            ).recordCount == 0 
        ) {
            abort;
        };

        // for 4.1
        //baseDir = ExpandPath("/ioffice/batch/");
        // for 4.2
        baseDir = "#new PDFDirectory().getPDFBaseDirectoryPath()#/content/";
        list = DirectoryList("#baseDir#bat", false, "name", "*.log");
        for( i = 1; i <= list.len(); i++ ) {
            newFileName = list[i].replace(".log", DateFormat(Now(), "yyyy-mm-dd") & ".log", "all");
            if( !DirectoryExists("#baseDir#/bat-backups") ) {
                DirectoryCreate("#baseDir#/bat-backups");
            }
            FileCopy(
                "#baseDir#/bat/#list[i]#", 
                "#baseDir#/bat-backups/#newFileName#"
            );
        }
    
        backupList = DirectoryList("#baseDir#/bat-backups/", false, "name");
        for( i = 1; i <= backupList.len(); i++ ) {
            fileInfo = GetFileInfo("#baseDir#/bat-backups/#backupList[i]#");
            if( DateCompare(fileInfo.lastModified, DateAdd("d", -30, Now())) == 1 ) {
                FileDelete(fileInfo.path);
            }
        }
    }
    catch(any error) {
        WriteDump(error);
    }
</cfscript>
