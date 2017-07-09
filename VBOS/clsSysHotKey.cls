VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsSysHotKey"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

'---------------- ϵͳ�ȼ� ----------------
'��Ҫ mdlSysHotKeySupport ��׼ģ���֧��
'��Ҫ clsHashLK��clsStack��clsSubClass ��ģ�� �� mdlSubClass ��׼ģ���֧��

'#��ʾ��Ϣ�ַ��������ѹ��ʻ��������Ǿ�̬�����������滻ռλ���ţ��粻 _
 �Ƕ�����԰汾���ɲ����� mdlRes ģ��

'#���ʻ��ַ���������
#If Not con_MulLang Then
    Private Const syhkResStr1 As String = "ϵͳ�ȼ�����ɹ���"
    Private Const syhkResStr2 As String = "(��)"
    Private Const syhkResStr3 As String = "ϵͳ�ȼ�����ʧ�ܡ�������ָ��һ���������ȼ���"
#End If


'================================================================================
'һ��������ֻ����һ��ϵͳ�ȼ�
'����ϵͳ�ȼ� ID ��˵����
'������һ������������һ���ȼ�ID�ˣ�lIDSysHotKey ����Ч��Χ1��32767���� _
 '�� ID ����������������������ұ��ֲ��䣬�����۵�ǰ�������Ƿ�������һ��ϵͳ�ȼ�
'�����ȼ�ʱ����ʹ�ø�ID��ȡ�������ȼ�ʱ���Ա�����ID�����´������������ȼ�ʱʹ��
'��ID���� Class_Initialize ʱ���� mdlSysHotKeySupport �����
'�ڶ��� Class_Terminate ʱ���� mdlSysHotKeySupport �ͷ�ID
'����ڱ����������ڼ䣬lIDSysHotKey=0���򱾶��������ڹ����κ�ϵͳ�ȼ����� _
 '��������ʹ��
'================================================================================


Private Declare Function RegisterHotKey Lib "user32" (ByVal hwnd As Long, ByVal id As Long, ByVal fsModifiers As Long, ByVal vk As Long) As Long
Private Declare Function UnregisterHotKey Lib "user32" (ByVal hwnd As Long, ByVal id As Long) As Long

Private Const MOD_CONTROL = &H2
Private Const MOD_SHIFT = &H4
Private Const MOD_ALT = &H1
Private Const MOD_WIN = &H8


Public Event SysKeyPressed()

Private lHwnd As Long    'Ŀ�괰����
Private lKeyCode As Long    '������������ȼ����������
Private lShift As Long  '������������ȼ�����ϼ�
Private lIDSysHotKey As Long  'ϵͳ�ȼ�ID
Private lIsSysHotKeySet As Boolean    '�Ƿ���ͨ��������������һ��ϵͳ�ȼ�

Private mHashVKSpe As clsHashLK    '���ⰴ������������������Ӧ��ϵ��Key=������룬DataString=����

Public Sub RaiseSysKeyPressedEvent()
    RaiseEvent SysKeyPressed
End Sub

Public Function SetASysHotKey(ByVal hwnd As Long, _
                              ByVal kKeyCode As Long, _
                              ByVal kShift As Long, _
                              Optional ByVal bShowMsg As Boolean = True) As Boolean

'����ϵͳ�ȼ�
'hwnd��������
'KeyCode�������������
'Shift��ΪAlt(=1),Control(=2),Shift(=4),WinKey(=8)�����
'bShowMsg���Ƿ���ʾ�ɹ���ʧ��

    If lIDSysHotKey = 0 Then GoTo errH    '������û���ȼ�ID������ʹ��
    If KeyCode < 0 Or Shift < 0 Then GoTo errH

    '======== ����ϵͳ�ȼ���ID Ϊ lIDSysHotKey ========
    Dim ret As Long
    ret = RegisterHotKey(hwnd, lIDSysHotKey, kShift, kKeyCode)
    If ret = 0 Then GoTo errH    '����ʧ��

    '======== ���໯���� hwnd���Զ��崰�ڳ���Ϊ _
     'mdlSysHotKeySupport ģ��� SHKWndProc ����  ========
    '�� mdlSysHotKeySupport �������໯����׼ģ����ֹ�ظ����໯
    If Not SHKSubClassHwnd(hwnd) Then GoTo errH

    '======== ϵͳ�ȼ����óɹ� ========
    '��ز�����ֵ��ģ�鼶���Ա���
    lHwnd = hwnd
    lKeyCode = kKeyCode
    lShift = kShift
    lIsSysHotKeySet = True

    '��ʾ��ʾ��Ϣ��������ȼ���ʲô
    If bShowMsg Then
        Dim strHotKey As String
        strHotKey = ShiftStr()
        If strHotKey = syhkResStr2 Then strHotKey = "" Else strHotKey = strHotKey & " + "
        strHotKey = strHotKey & KeyCodeStr() & " (KeyCode=" & CStr(KeyCode) & ")"
        MsgBox syhkResStr1 & strHotKey, vbInformation
    End If

    '���سɹ�
    SetASysHotKey = True
    Exit Function
errH:
    SetASysHotKey = False
    If bShowMsg Then MsgBox syhkResStr3, 16
End Function


Public Sub UnSetSysHotKey()
'ȡ��ͨ�����������ù���һ��ϵͳ�ȼ��� _
  '������������� lIDSysHotKey���Ա������ñ����������µ�ϵͳ�ȼ�
'ֻ���� Class_Terminate ʱ�����ͷ� lIDSysHotKey

    If lIsSysHotKeySet Then
        'ȡ��ϵͳ�ȼ�
        UnregisterHotKey lHwnd, lIDSysHotKey

        'ȡ�����໯ lhwnd
        '�� mdlSysHotKeySupport ����ȡ�����໯����׼ģ����ֹȡ������ʹ�õ����໯
        SHKUnSubClassHwnd lHwnd

        '������0
        lHwnd = 0
        lKeyCode = 0
        lShift = 0
        '������� lIDSysHotKey��ֻ���� Class_Terminate ʱ�������
        lIsSysHotKeySet = False
    End If
End Sub









Public Sub ToComboShifts(tComboBox As ComboBox)
'�� Shift,Alt,Ctrl,WinKey ���ĸ���������ӵ� tComboBox �б�
'���Ұ� tComboBox �� ItemData ����Ϊ��ϼ�����ֵ��������������ȼ��ĳ������
    Dim i As Integer
    With tComboBox
        tComboBox.Clear
        For i = 0 To 15
            .AddItem ShiftStr(i)
            .itemData(.ListCount - 1) = i
        Next i
        If .ListCount Then .ListIndex = 0
    End With
End Sub

Public Sub ToComboKeys(tComboBox As ComboBox)
'�������ȼ��ĸ��ּ����ӵ� tComboBox �б�
'���Ұ� tComboBox �� ItemData ����Ϊ��Ӧ����������룬������������ȼ��ĳ������

    Dim arrKeys() As Long
    Dim i As Long
    With tComboBox
        .Clear
        'F1-F12 ���ܼ�
        For i = 1 To 12
            .AddItem "F" & CStr(i)
            .itemData(.ListCount - 1) = 111 + i
        Next i
        '��ĸ��
        For i = 1 To 26
            .AddItem Chr(64 + i)
            .itemData(.ListCount - 1) = 64 + i
        Next i
        '���ּ�
        For i = 0 To 9
            .AddItem Chr(48 + i)
            .itemData(.ListCount - 1) = 48 + i
        Next i

        '�����
        For i = 1 To mHashVKSpe.GetKeyArray(arrKeys)
            .AddItem mHashVKSpe.DataString(arrKeys(i))
            .itemData(.ListCount - 1) = arrKeys(i)
        Next i

        'С�������ּ�
        For i = 0 To 9
            .AddItem "NumPAD:" & Chr(48 + i)
            .itemData(.ListCount - 1) = 96 + i
        Next i

        'Ĭ��ѡ�е�0��
        If .ListCount Then .ListIndex = 0
    End With
End Sub


Public Function ShiftStr(Optional ByVal kShift As Long = -1) As String
'��ϵͳ�ȼ�����ϼ� kShift ת��Ϊ�ַ���˵��
'ȱʡת�������󱣴��ϵͳ�ȼ�����ϼ� lShift ����
    Dim strResu As String

    If kShift < 0 Then kShift = lShift
    If kShift < 0 Then ShiftStr = "": Exit Function

    If kShift And MOD_CONTROL Then strResu = strResu & "Ctrl + "
    If kShift And MOD_ALT Then strResu = strResu & "Alt + "
    If kShift And MOD_SHIFT Then strResu = strResu & "Shift + "
    If kShift And MOD_WIN Then strResu = strResu & "WinKey + "

    If Len(strResu) Then
        strResu = Left(strResu, Len(strResu) - 3)    '��ȥ����" + "
    Else
        strResu = syhkResStr2
    End If
    ShiftStr = strResu
End Function

Public Function KeyCodeStr(Optional ByVal kKeyCode As Long = -1) As String
'��������� kKeyCode ת��Ϊ�ַ���˵��
'ȱʡת�������󱣴��ϵͳ�ȼ��İ������� lKeyCode

    If kKeyCode < 0 Then kKeyCode = lKeyCode
    If kKeyCode < 0 Then KeyCodeStr = "": Exit Function

    Select Case kKeyCode
    Case 112 To 123
        'F1-F12���ܼ�
        KeyCodeStr = "F" & CStr((kKeyCode - 111))
    Case 96 To 105
        'С�������ּ�
        KeyCodeStr = "NumPAD:" & Chr(kKeyCode - 48)
    Case Else
        If mHashVKSpe.IsKeyExist(kKeyCode) Then
            KeyCodeStr = mHashVKSpe.DataString(kKeyCode, False)
        Else
            KeyCodeStr = Chr(kKeyCode)
        End If
    End Select
End Function





Private Sub Class_Initialize()
'�ڱ����������ڣ���Ҫ�� mdlSysHotKeySupport ����һ���ȼ� ID�� _
  '������ lIDSysHotKey �У�ͬʱ�� mdlSysHotKeySupport �ǼǱ����� _
  '��ַ���ID�Ķ�Ӧ��ϵ
'�ڱ����� Class_Terminate ʱ���� mdlSysHotKeySupport ȡ�� _
  '�˵Ǽǲ��ͷ��ȼ� ID

'�������ܷ���0��ʾʧ�ܣ���ʱ lIDSysHotKey Ϊ 0�����ܼ���ʹ�ñ�������ϵͳ�ȼ�
    lIDSysHotKey = SHKRegOneObject(ObjPtr(Me))


    '------ ��ʼ�������������� ------
    Dim s() As String, i As Integer
    Set mHashVKSpe = New clsHashLK
    mHashVKSpe.AlloMem 255

    mHashVKSpe.Add 0, 8, 0, "Backspace", False
    mHashVKSpe.Add 0, 9, 0, "Tab", False
    mHashVKSpe.Add 0, 13, 0, "Return", False
    mHashVKSpe.Add 0, 19, 0, "Pause", False
    mHashVKSpe.Add 0, 44, 0, "PrintScreen", False
    mHashVKSpe.Add 0, 45, 0, "Insert", False
    mHashVKSpe.Add 0, 46, 0, "Delete", False
    mHashVKSpe.Add 0, 91, 0, "LeftWin", False
    mHashVKSpe.Add 0, 92, 0, "RightWin", False
    mHashVKSpe.Add 0, 93, 0, "App", False
    mHashVKSpe.Add 0, 20, 0, "CapsLock", False
    mHashVKSpe.Add 0, 144, 0, "NumLock", False
    mHashVKSpe.Add 0, 145, 0, "ScrollLock", False
    '32-40
    s = Split("SPACE,PageUp,PageDown,END,HOME,LEFT,UP,RIGNT,DOWN", ",")
    For i = 0 To UBound(s)
        mHashVKSpe.Add 0, i + 32, 0, s(i), False
    Next i
    '106-111
    s = Split("NumPAD:*,NumPAD:+,NumPAD:Sep,NumPAD:-,NumPAD:.,NumPAD:/", ",")
    For i = 0 To UBound(s)
        mHashVKSpe.Add 0, i + 106, 0, s(i), False
    Next i
End Sub

Private Sub Class_Terminate()
'ȡ��ͨ�����������ù���һ��ϵͳ�ȼ�������еĻ���
    UnSetSysHotKey

    '�� mdlSysHotKeySupport ȡ���Ǽǲ��ͷ��ȼ� ID��lIDSysHotKey
    SHKUnRegOneObject lIDSysHotKey

    '�ͷ� mHashVKSpe ����
    Set mHashVKSpe = Nothing
End Sub

















'Ŀ�괰�ھ����ֻ�����ԣ�
Public Property Get hWndNotify() As Long
    hWndNotify = lHwnd
End Property

'�ȼ�������루ֻ�����ԣ�
Public Property Get KeyCode() As Long
    KeyCode = lKeyCode
End Property

'�ȼ�������ϼ���ֻ�����ԣ�
Public Property Get Shift() As Long
    Shift = lShift
End Property

'�����������Ƿ��Ѿ�������һ��ϵͳ�ȼ���ֻ�����ԣ�
Public Property Get IsSysHotKeySet() As Boolean
    IsSysHotKeySet = lIsSysHotKeySet
End Property


'ϵͳ�ȼ� ID ����������������������ڣ���ֵ���䣩��ֻ�����ԣ�
Public Property Get IDSysHotKey() As Long
    IDSysHotKey = lIDSysHotKey
End Property

