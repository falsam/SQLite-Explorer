;SQLite Explorer (falsam)
;
;PB 4.31
;

EnableExplicit

Enumeration Font
  #FontGlobal
EndEnumeration

Enumeration Window
  #MainForm
EndEnumeration

Enumeration gadget
  #DatabaseSelect                ;Selecteur de base de données
  #DataBase                      ;Base de données en cours de visualisation
  #ReqSql                        ;Saisie des requêtes SQL
  #ListTables                    ;Liste des tables 
  #ListRows                      ;Contenue d'une table
  #Report
  #Help
  #Splitter1
  #Splitter2
  #Splitter3
EndEnumeration

Enumeration ShortCut
  #F5                            ;Execution d'une requête
  #Home                          ;Premiere requete SQL (Ctrl + Home)
  #End                           ;Derniere requete SQL (Ctrl + End)
  #PageUp                        ;Requete SQL précédente
  #PageDown                      ;Requete SQL suivante
EndEnumeration

Structure NewReqSql
  ReqSql.s
EndStructure

Global NewList ReqSql.NewReqSql()  ;Mémorisation des requétes SQL

;Plan de l'application
Declare MainFormShow()          ;Fenetre principale de l'application
Declare ShowReport(Buffer.s)    ;Affichage du rapport d'éxécution

Declare WorkReqSqlLoad()        ;Chargement des requêtes SQL associées à la base de données sélectionnée
Declare WorkReqSqlSave()        ;Sauvegarde des requêtes SQL associées à la base de données sélectionnée

Declare OnDataBaseSelect()      ;Une base de données est sélectionnée
Declare DataBaseListTable()     ;Affichage des tables de la base de données 
Declare OnTableSelect()         ;Une table est sélectionnée 

Declare OnReqSQLExe()           ;Une requête SQL est éxécutée
Declare OnReqSQLSelect()        ;Défilement & Selection d'une requête SQL
Declare OnReqSQLError(ReqSql.s) ;Erreur lors de l'éxéctution d'une requête SQL

Declare OnResizeWindow()        ;Resize Window
Declare OnCloseWindow()         ;Fin de l'application

UseSQLiteDatabase()

MainFormShow()

;Fenetre principale de l'application
Procedure MainFormShow()
  LoadFont(#FontGlobal, "", 10)
  SetGadgetFont(#PB_Default, FontID(#FontGlobal))
  
  If OpenWindow(#MainForm, 0, 0, 1020, 760, "SQlite Explorer", #PB_Window_ScreenCentered|#PB_Window_SizeGadget|#PB_Window_MaximizeGadget)      
    
    ;Selecteur de base de données 
    ButtonGadget(#DatabaseSelect, 410, 10, 22, 22, "?")
    GadgetToolTip(#DatabaseSelect, "Selectionner une base de données")
    
    ;Base de donnée en cours de consultation
    TextGadget(#PB_Any, 10, 15, 100, 20, "Database")
    StringGadget(#Database, 105, 10, 300, 22, "?", #PB_String_ReadOnly)
    
    ;Affichage de l'editeur de requete SQL (haut de la fenetre)
    EditorGadget(#ReqSQL, 0, 0, 0, 0)
    
    ;Affichage des tables et de la structure de chaque table (Gauche de la fenetre)
    TreeGadget(#ListTables, 0, 0, 0, 0)
    
    ;Affichage du contenu d'une table sélectionneé dans #ListTables (Droite de la fenetre)
    ListIconGadget(#ListRows, 0, 0, 0, 0, "?", 1000, #PB_ListIcon_FullRowSelect|#PB_ListIcon_GridLines|#PB_ListIcon_HeaderDragDrop)
    
    ;Debug (Bas de la fenetre)
    ListViewGadget(#Report, 0, 0, 0, 0)
    
    ;Zone d'aide
    TextGadget(#Help, 10, 735, 1000, 22, "[F5] Run SQL  -  [Ctrl + Home], [Ctrl + End], [PageUp], [PageDown] Select query sql.")
    
    ;Mise en place ds splitters
    SplitterGadget(#Splitter1, 10, 40, 1000, 690, #ListTables, #ListRows, #PB_Splitter_Vertical|#PB_Splitter_FirstFixed)
    SetGadgetState(#Splitter1, 200) ;Positionne le splitter 1 à 200 px du bord gauche
    
    SplitterGadget(#Splitter2, 10, 40, 1000, 690, #ReqSql, #Splitter1, #PB_Splitter_FirstFixed)
    SetGadgetState(#Splitter2, 100) ;Positionne le splitter 2 à 100 px du bord haut
    
    SplitterGadget(#Splitter3, 10, 40, 1000, 690, #Splitter2, #Report, #PB_Splitter_SecondFixed)
    SetGadgetState(#Splitter3, 600) ;Positionne le splitter 3 à 600 px du bord haut
    
    ;Shortcuts
    AddKeyboardShortcut(#MainForm, #PB_Shortcut_F5, #F5)                            ;Exécution d'une requéte SQL
    AddKeyboardShortcut(#MainForm, #PB_Shortcut_Control|#PB_Shortcut_Home, #Home)   ;Premiere requete SQL
    AddKeyboardShortcut(#MainForm, #PB_Shortcut_Control|#PB_Shortcut_End, #End)     ;Derniere requete SQL
    AddKeyboardShortcut(#MainForm, #PB_Shortcut_PageDown, #PageDown)                ;Requete SQL précédente
    AddKeyboardShortcut(#MainForm, #PB_Shortcut_PageUp, #PageUp)                    ;Requete SQL suivante
    
    ;Evenements
    BindGadgetEvent(#DatabaseSelect, @OnDataBaseSelect(), #PB_EventType_LeftClick)  ;Une base de donnés est sélectionnée
    BindGadgetEvent(#ListTables, @OnTableSelect(), #PB_EventType_LeftClick)         ;Une table est sélectionnée
    BindEvent(#PB_Event_Menu, @OnReqSQLExe(), #MainForm, #F5)                       ;Une requête SQL est éxécutée
    BindEvent(#PB_Event_Menu, @OnReqSQLSelect(), #MainForm, #Home)                  ;Sélection de la premiere requete SQL
    BindEvent(#PB_Event_Menu, @OnReqSQLSelect(), #MainForm, #End)                   ;Sélection de la derniere requete SQL
    BindEvent(#PB_Event_Menu, @OnReqSQLSelect(), #MainForm, #PageUp)                ;Sélection de la requete SQL précédente
    BindEvent(#PB_Event_Menu, @OnReqSQLSelect(), #MainForm, #PageDown)              ;Sélection de la requete SQL suivante
    
    BindEvent(#PB_Event_SizeWindow, @OnResizeWindow())                              ;Redimensionne la fenêtre
    BindEvent(#PB_Event_CloseWindow, @OnCloseWindow())                              ;Fermeture de l'application   
    
    Repeat : Until WaitWindowEvent(10) = #PB_Event_CloseWindow
  EndIf
EndProcedure

;Affichage du rapport d'éxécution
Procedure ShowReport(Buffer.s)
  Protected TimeStamp.s = "[" + FormatDate("%hh:%ii:%ss", Date()) + "] "
  
  AddGadgetItem(#Report, -1, TimeStamp + Buffer)
  SetGadgetState(#Report, CountGadgetItems(#Report) - 1)
EndProcedure

;Recherche de requêtes SQL associées à la base de données sélectionnée
Procedure WorkReqSqlLoad()
  Protected FileName.s = GetFilePart(GetGadgetText(#DataBase))
  Protected PathName.s = GetPathPart(GetGadgetText(#DataBase))
  Protected JSONName.s = PathName + Filename + ".json"
  Protected JSON 
  
  If ReadFile(0, JSONName)
    CloseFile(0)
    
    JSON = LoadJSON(#PB_Any, JSONName, #PB_JSON_NoCase)
    ExtractJSONList(JSONValue(JSON), ReqSql())
    FreeJSON(JSON)
    
    ShowReport("Vous avez " + Str(ListSize(ReqSql())) + " requétes mémorisées pour cette base de données.")
  EndIf
EndProcedure

;Sauvegardes des requetes SQL associées à la base de données sélectionnée
Procedure WorkReqSqlSave()
  Protected FileName.s = GetFilePart(GetGadgetText(#DataBase))
  Protected PathName.s = GetPathPart(GetGadgetText(#DataBase))
  Protected JSONName.s = PathName + Filename + ".json"
  
  Protected JSON = CreateJSON(#PB_Any)
  ;Si une base de données est déja ouverte ?
  ;Fermeture de la base de données  
  If IsDatabase(#Database)
    CloseDatabase(#DataBase)
    
    If ListSize(ReqSql()) > 0
      InsertJSONList(JSONValue(JSON), ReqSql())
      SaveJSON(JSON, JSONName, #PB_JSON_PrettyPrint)
      FreeJSON(JSON)
    EndIf
  EndIf
EndProcedure

;Une base de données est sélectionnée
Procedure OnDataBaseSelect()  
  Protected Database.s = OpenFileRequester("Selectionner une base de données SQLite", "*.sqlite", "", 0)
  
  ;Une base de données est sélectionnée
  If Database    
    WorkReqSqlSave()
    
    ;Reset des différents gadgets et table
    ClearGadgetItems(#ListTables)
    ClearGadgetItems(#ListRows)
    ClearGadgetItems(#Report)
    SetGadgetText(#ReqSql, "")
    SetGadgetText(#Database, Database)
    ClearList(ReqSql())
    
    ;Ouverture de la base de données sélectionnée
    ;Il s'agit d'une base de données SQLite
    ;Username & Password sont inutiles
    If OpenDatabase(#DataBase, Database, "","") 

      ;Affichage des tables
      DataBaseListTable()
    Else
      Debug "passe"
    EndIf
    
  EndIf
EndProcedure

;Affichage de la liste des tables et de la structure de chaque table
Procedure DataBaseListTable()
  Protected ReqSql.s, Table.s, Buffer.s , Dim Tables.s(0), n
  
  ;Extraction de la liste des tables
  ReqSQL="Select * From sqlite_master order by type Desc, name Asc"
  
  ShowReport(ReqSql)
  If DatabaseQuery(#Database, ReqSQL)  
    While NextDatabaseRow(#Database)
      If GetDatabaseString(#Database,0)="table"
        Tables(n) = GetDatabaseString(#Database,1)
        n+1 : ReDim Tables(n)
      EndIf  
    Wend
    
    ;Affichage des tables
    For n = 0 To ArraySize(Tables()) - 1
      AddGadgetItem(#ListTables, -1, Tables(n))
      
      ;Affichage de la Structure de chacune des tables
      ReqSQL="PRAGMA table_info(" + Chr(34) + Tables(n) + Chr(34) + ")"
      ShowReport(ReqSql)
      If DatabaseQuery(#Database, ReqSQL)
        While NextDatabaseRow(#Database)
          Buffer = GetDatabaseString(#Database, 1) + " " 
          Buffer + GetDatabaseString(#Database, 2) + " " 
          If GetDatabaseString(#Database, 5) = "1"
            Buffer + "PRIMARY KEY"
          EndIf
          
          AddGadgetItem(#ListTables, -1, Buffer, 0, 1)
        Wend
      Else
        OnReqSQLError(ReqSql)
      EndIf  
    Next
    
    WorkReqSqlLoad()            
  Else 
    OnReqSQLError(ReqSql)
  EndIf
EndProcedure

;Une table est sélectionnée
Procedure OnTableSelect()
  Protected Table.s, ReqSql.s
  
  If GetGadgetState(#ListTables) <> -1
    If GetGadgetItemAttribute(#ListTables, GetGadgetState(#ListTables), #PB_Tree_SubLevel) = 0 
      
      ;Mémorisation de la table à visualiser 
      Table = GetGadgetItemText(#ListTables, GetGadgetState(#ListTables))
      
      ;Création de la requéte
      ReqSql = "select * from " + Table + " limit 1, 100"
      SetGadgetText(#ReqSql, ReqSql)
    EndIf
  EndIf 
EndProcedure


;Si éxécution d'une requete SQL
;Affiche le contenue d'une table
Procedure OnReqSQLExe()
  Protected ReqSql.s, Buffer.s, Col.s, i
  
  ;Requete de sélection des enregistrements
  ReqSql = GetGadgetText(#ReqSql)
  
  ;Une base de données doit etre ouverte
  ;Existe t'il une requete ?
  If IsDatabase(#DataBase) And ReqSql <> ""    
    ClearGadgetItems(#ListRows)
    
    ;Suppression des colonnes existantes 
    While GetGadgetItemText(#ListRows, -1, 0)
      RemoveGadgetColumn(#ListRows, 0)
    Wend
    
    ;Exécution de la requête SQL
    ShowReport(ReqSql)
    If DatabaseQuery(#Database, ReqSQL)
      
      ;AJout des colonnes
      For i = 0 To DatabaseColumns(#Database) - 1
        Col = DatabaseColumnName(#DataBase, i)
        AddGadgetColumn(#ListRows, i, Col, 100)
      Next     
      
      ;Affichage du contenu de la table
      While NextDatabaseRow(#DataBase)
        For i = 0 To DatabaseColumns(#DataBase) - 1
          Buffer + GetDatabaseString(#DataBase, i) + Chr(10)
        Next
        AddGadgetItem(#ListRows, -1, Buffer)
        Buffer = ""
      Wend
      
      ;Sauvegarde de la requéte
      If ListSize(ReqSql()) = 0 Or ReqSql <> ReqSql()\ReqSql
        AddElement(ReqSql())
        ReqSql()\ReqSql = ReqSql
      EndIf
    Else
      OnReqSQLError(ReqSql)
    EndIf
  EndIf
EndProcedure

;Défilement & Selection d'une requete
Procedure OnReqSQLSelect()  
  If ListSize(ReqSql()) <> 0    
    Select EventMenu()
      Case #Home ;Premiere requête
        FirstElement(ReqSql())
        
      Case #End ;Derniere requête
        LastElement(ReqSql())
        
      Case #PageUp ;Requête précédente
        PreviousElement(ReqSql())
        
      Case #PageDown ;Requête suivante
        NextElement(ReqSql())
        
    EndSelect
    
    SetGadgetText(#ReqSql, ReqSql()\ReqSql)
  Else
    ShowReport("Aucune requête mémorisée !")
  EndIf
  
EndProcedure

;Si Erreur durant l'éxécution d'une requête SQL
Procedure OnReqSQLError(ReqSql.s)
  ShowReport(DatabaseError())
EndProcedure

;Redimensionne la fenetre principale
Procedure OnResizeWindow()
  Protected Width = WindowWidth(#MainForm)
  Protected Height = WindowHeight(#MainForm) 
  
  ResizeGadget(#Splitter3, #PB_Ignore, #PB_Ignore, Width-20, Height-70)
  ResizeGadget(#Help, #PB_Ignore, Height - 25, Width-20, #PB_Ignore)
EndProcedure

;Fermeture de l'application
Procedure OnCloseWindow()   
  WorkReqSqlSave()
  End
EndProcedure
