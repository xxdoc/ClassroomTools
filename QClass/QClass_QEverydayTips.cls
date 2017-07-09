VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "QClass_QEverydayTips"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
Option Explicit
'----------------------------------ShowGraphics()----------------------------------
Private Const MaxPicNum As Integer = 2048    '�����Զ���ȡ�ļ����е����ͼƬ����
Private sPath As String    'ͼƬ�ļ���·��
Private PicList(1 To MaxPicNum) As String    'ͼƬ�б�
Private OrderList() As String    'ͼƬ˳���б�
Private PicCount As Integer    'ͼƬ����
Private IsGraphicsInit As Boolean    '�Ƿ��Ѿ���ʼ��ͼ��

Function InitFile(FileName As String, OutputFileName As String) As Boolean
    On Error GoTo Err
    'Doc: ����ͨ�ı��ļ�ת����CQAFʹ�õĸ�ʽ
    If Len(Dir(FileName)) = 0 Then
        InitFile = False
        Exit Function
    End If
    Dim FileNum As Integer, strTmp As String, i As Integer
    i = 1
    FileNum = FreeFile
    QApp.QSettings.SaveToFile OutputFileName, "def", "title", Mid(FileName, InStrRev(FileName, "\") + 1)    '�����ļ�����
    Open FileName For Input As FileNum
    Do While Not EOF(FileNum)
loadFile:
        Line Input #FileNum, strTmp
        If Len(Trim(strTmp)) = 0 Then    '��������
            GoTo loadFile
        End If
        QApp.QSettings.SaveToFile OutputFileName, "line", Str(i), Mid(Trim(strTmp), 7)
        i = i + 1
    Loop
    Close FileNum
    QApp.QSettings.SaveToFile OutputFileName, "def", "line_count", Trim(Str(i - 1))    '�����ļ�����
    Exit Function
Err:
    QDB.Runtime_Error "QClass_QEverydayTips->InitFile()", Err.Description, Err.Number
End Function

Function ShowText(SelectItem As Integer) As String     '��ʾ
    On Error GoTo Err
    Dim FilePath As String
    Dim strTmp As String, i As Integer, line As Integer

    FilePath = App.Path & "\Resource\"
    Dim FileName As String
    Select Case SelectItem
        Case 1: FileName = "����Щ�꣬����һ��׷��Ů����������¼"
        Case 2: FileName = "���ݱ���������¼"
        Case 3: FileName = "��̾�����¼"
        Case 4: FileName = "��������Ĭ��¼"
        Case 5: FileName = "Ψ����ʫ��"
        Case 6: FileName = "�����޶���"
        Case 7: FileName = "Сѧ����Ӣ��"
        Case 8: FileName = "���ഺ����̨��22��"
    End Select

    FilePath = FilePath & FileName & ".qdat1"

    Randomize
    line = Val(QApp.QSettings.ReadFromFile(FilePath, "def", "line_count"))
    i = Int((line - 0 + 1) * Rnd + 0)    'ȡ�����
    strTmp = QApp.QSettings.ReadFromFile(FilePath, "line", Str(i))
    QApp.Tray_ShowText QApp.QSettings.ReadFromFile(FilePath, "def", "title"), strTmp
    ShowText = strTmp
    Exit Function
Err:
    QDB.Runtime_Error "QClass_QEverydayTips->ShowText()", Err.Description, Err.Number
End Function

Function ShowGraphics() As StdPicture
    On Error GoTo Err
    Static k As Long    '��ǰ�ŵ���ͼƬ���
    Dim Order As Long  '���ͼƬ˳��
    Dim PicName As String

    If Not IsGraphicsInit Then
        Exit Function
    End If

LoopI:
    k = 1
    If k > PicCount Then    'ȫ��ͼƬ���꣬����˳���б�
        k = 1
        Dim sb As Long
        For sb = 1 To PicCount
            OrderList(sb) = ""
        Next
    End If

    '��ȡ���˳��
    Randomize
    Order = Int((PicCount + 1) * Rnd) + 1

    '���ظ��㷨
    Dim II As Long
    For II = 1 To PicCount
        If PicList(Order) = OrderList(II) Then
            GoTo LoopI
        End If
    Next

    PicName = PicList(Order)    '��ͼƬ�б��ж�ȡ�ļ���
    If Len(PicName) = 0 Then Exit Function    'û���ļ������˳�
    QDB.Log "Order=" & Order & " " & " PicName=" & PicName
    OrderList(k) = PicName    '�ù���ͼƬ��������
    k = k + 1

    Dim tmpPic As StdPicture
    Set tmpPic = LoadPicture(PicName)
    QFrm_Tray.ShowTrayGraphics "�����ޱ����", "", tmpPic
    Set ShowGraphics = tmpPic    '����ͼƬ
    Set tmpPic = Nothing    '����ͷ��ڴ�
    Exit Function
Err:
    QDB.Runtime_Error "QClass_QEverydayTips->ShowGraphics()", Err.Description, Err.Number
End Function

Function GraphicsInit()    'ͼ��ģʽ��ʼ��
    On Error GoTo Err
    sPath = App.Path & "\Resource\pic"    '����ͼƬ�ļ���

    If Dir(sPath, vbDirectory) <> "" Then    '����ļ����Ƿ����
        '��ȡͼƬ�б�
        Dim FileName As String
        Dim ItemIndex As Long
        FileName = Dir(sPath & "\", vbNormal)
        Do While Len(FileName) > 0
            ItemIndex = ItemIndex + 1
            PicCount = PicCount + 1
            PicList(ItemIndex) = sPath & "\" & FileName
            DoEvents    '��ֹ�������
            FileName = Dir    '�ٻ�ȡһ��
            QDB.Log "QClass_QEverydayTips->ShowGraphics()->GetPicList,PicFileName(" & ItemIndex & ")=" & FileName
        Loop
        If PicCount > 0 Then
            ReDim OrderList(1 To PicCount)
        End If
    End If
    IsGraphicsInit = True    '״̬��ͼ��ģʽ�Ѿ���ɳ�ʼ��
    Exit Function
Err:
    QDB.Runtime_Error "QClass_QEverydayTips->GraphicsInit()", Err.Description, Err.Number
End Function