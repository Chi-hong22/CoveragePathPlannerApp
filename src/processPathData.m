%% processPathData - ����·�����ݲ�ת��ΪJSON��ʽ
%
% ����������
%   �ú������ڴ���·�����ݣ���������������ת��ΪJSON��ʽ��
%
% ������Ϣ��
%   ���ߣ�Chihong�����Ӱ���
%   ���䣺you.ziang@hrbeu.edu.cn
%   ��λ�����������̴�ѧ
%
% �汾��Ϣ��
%   ��ǰ�汾��v1.0
%   �������ڣ�250329
%   ����޸ģ�250329
%
% �汾��ʷ��
%   v1.0 (250329) - �״η���
%       + ʵ��·�����ݵĴ�����
%       + ��ӻ����Ĵ������״̬����
%
% ���������
%   app         - [object] MATLAB App���󣬰���UI�ؼ���״̬��Ϣ
%   pathData    - [double array] ·�����ݾ�������Ϊ·��������������Ϊ2��4
%
% ���������
%   jsonData    - [string] ������·�����ݣ�JSON��ʽ
%   statusData  - [logical] ���ݴ����״̬��true��ʾ�ɹ���false��ʾʧ�ܣ�
%   errorMessage - [string] ������ݴ���ʧ�ܣ����ش�����Ϣ
%
% ע�����
%   1. ·�����ݵ���������Ϊ2��4��������׳�����
%   2. �ϸ������Ǳ�������������·����������Χ��
%   3. ��������÷��Ͱ�ť��ֱ��������ɻ�ʧ��
%
% ����ʾ����
%   % ʾ��1����������
%   [jsonData, statusData, errorMessage] = processPathData(app, pathData);
%
% ���������䣺
%   - MATLAB App Designer
%
% �μ�������
%   jsonencode, assignin
function [jsonData, statusData, errorMessage] = processPathData(app, pathData)
    try
        % ��ȡ������źͿ���״̬
        Kdelta = [app.Kdelta1EditField.Value, app.Kdelta2EditField.Value, app.Kdelta3EditField.Value, app.Kdelta4EditField.Value];
        Delta = [app.Delta1EditField.Value, app.Delta2EditField.Value, app.Delta3EditField.Value, app.Delta4EditField.Value];
        % ��ȡ�����ٶȣ�����ʱ��ͼ�ͣʱ��
        ud = app.udEditField.Value;
        Td = app.TdEditField.Value;
        Tj = app.TjEditField.Value;

        % ��ȡ��ʼλ�ú���̬��
        P0 = [app.P0XEditField.Value, app.P0YEditField.Value, app.P0ZEditField.Value];
        A0 = [app.A0XEditField.Value, app.A0YEditField.Value, app.A0ZEditField.Value];

        % ��ȡIP
        hostIP = app.hostIPEditField.Value;
        hPort = app.hPortEditField.Value;

        % ��ȡ·���������ʹ���Z����
        WPNum = size(pathData, 1);
        numColumns = size(pathData, 2);

        % �����������в�ͬ�Ĳ���
        if numColumns == 4
            % ����� 4 �У�ɾ���� 3 �к͵� 4 ��
            pathData(:, 3:4) = [];
            % ����һ�� Z ����
            column_of_z = app.ZEditField.Value * ones(size(pathData, 1), 1);
            pathData = [pathData, column_of_z];
        elseif numColumns == 2
            % ����� 2 �У�����һ�� Z ����
            column_of_z = app.ZEditField.Value * ones(size(pathData, 1), 1);
            pathData = [pathData, column_of_z];
        else
            % ����������� 2 �� 4���׳��������ʾ
            error('·�����ݵ�����������2��4');
        end

        % �ϸ�����
        upinputStr = app.upEditField.Value;
        try
            upvector = str2num(upinputStr); % ʹ�� str2num ���ַ���ת��Ϊ��ֵ
        catch
            uialert(app.UIFigure, '�����ʽ���������붺�Ż�ո�ָ������֡�', '����');
        end

        for i = 1:length(upvector)
            rowIdx = upvector(i); % ��ȡ������
            if rowIdx <= size(pathData, 1) % ����������Ƿ���Ч
                pathData(rowIdx, 3) = app.DupEditField.Value; % ���µ�����
            else
                app.TotalLengthLabelandTCP.Text = '�ϸ���/��Ǳ�����������ܺ���';
                app.TotalLengthLabelandTCP.FontColor = [0 0 0.8];
            end
        end
        up = upvector(1); % ��ʼ�ϸ�������

        % ��Ǳ����
        downinputStr = app.downEditField.Value;
        try
            downvector = str2num(downinputStr); % ʹ�� str2num ���ַ���ת��Ϊ��ֵ
        catch
            uialert(app.UIFigure, '�����ʽ���������붺�Ż�ո�ָ������֡�', '����');
        end

        for i = 1:length(downvector)
            rowIdx = downvector(i); % ��ȡ������
            if rowIdx <= size(pathData, 1) % ����������Ƿ���Ч
                pathData(rowIdx, 3) = app.DdownEditField.Value; % ���µ�����
            else
                app.TotalLengthLabelandTCP.Text = '�ϸ���/��Ǳ�����������ܺ���';
                app.TotalLengthLabelandTCP.FontColor = [0 0 0.8];
            end
        end
        down = downvector(1); % ��ʼ��Ǳ������

        % ê��������
        anchor = app.anchorEditField.Value;
        anchorvector = str2num(anchor);
        z_sorted = sort(anchorvector, 'descend');
        valid_z = z_sorted(z_sorted <= size(pathData, 1));
        z_sorted = valid_z;

        for row = z_sorted
            current_row = pathData(row, :);
            pathData = [pathData(1:row, :);
                repmat(current_row, 2, 1);
                pathData(row+1:end, :)];
        end
        % ê��ʱ��
        tm=app.TanchorEditField.Value;

        WPNum = size(pathData, 1);
        z = app.ZEditField.Value; % �������

        % ����ԭ�е�assignin���
        assignin('base', 'z', z);
        assignin('base', "Waypoints", pathData);
        assignin('base', 'WPNum', WPNum);
        assignin('base', 'P0', P0);
        assignin('base', 'A0', A0);
        assignin('base', 'Kdelta', Kdelta);
        assignin('base', 'Delta', Delta);
        assignin('base', 'ud', ud);
        assignin('base', "Td", Td);
        assignin('base', "Tj", Tj);
        assignin('base', 'up', up);
        assignin('base', "down", down);
        assignin('base', "tm", tm);

        % �������ݽṹ
        dataStruct = struct('Waypoints', pathData, ...
                            'WPNum', WPNum, ...
                            'P0', P0, ...
                            'A0', A0, ...
                            'Kdelta', Kdelta, ...
                            'Delta', Delta, ...
                            'ud', ud, ...
                            'Td', Td, ...
                            'Tj', Tj, ...
                            'up', up, ...
                            'down', down, ...
                            'z', z, ...
                            'hostIP', hostIP, ...
                            'hPort', hPort, ...
                            'tm',tm);
        % ת��ΪJSON
        jsonData = jsonencode(dataStruct);
        statusData = true;
        errorMessage = '';
    catch dataErr
        jsonData = '';
        statusData = false;
        errorMessage = ['��������׼��ʧ��: ', dataErr.message];
        app.TotalLengthLabelandTCP.Text = errorMessage;
        app.TotalLengthLabelandTCP.FontColor = [0.8 0 0];
    end
end