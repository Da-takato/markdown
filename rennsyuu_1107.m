clear;
tic;
syms g R positive;
m = sym('m%d', [12,1], 'positive');
L = sym('L%d', [6,1], 'positive');
lg = sym('lg%d', [6,1], 'positive');
Ixx = sym('Ixx%d',[1,6],'positive');
Iyy = sym('Iyy%d',[1,6],'positive');
Izz = sym('Izz%d',[1,6],'positive');
theta  = sym('theta%d', [12,1], 'real');
dtheta  = sym('dtheta%d', [12,1], 'real');

% --- 基本DHテーブル（例として指1のみ定義、指2,3も同様に可） ---
DH =  [ 0,    pi/2,     0,        pi/2;
        0,       0,     0,    theta(1);
      -L(1),  pi/2,     0,    theta(2);  
      -L(2),     0,     0,    theta(3);
      -L(3),     0,     0,          0];

DH1 = [DH;
       0,  -2*pi/3,    -R,            0;
       0,    -pi/2,     0,        -pi/4;
       0,     pi/2,     0,     theta(4);
      -L(4),  pi/2,     0,     theta(5); 
      -L(5),     0,     0,    theta(6)];
DH2 = [DH;
       0,        0,    -R,            0;
       0,    -pi/2,     0,        -pi/4;
       0,     pi/2,     0,     theta(7);
      -L(4),  pi/2,     0,     theta(8); 
      -L(5),     0,     0,    theta(9)];
DH3 =[ DH;
       0,   2*pi/3,    -R,            0;
       0,    -pi/2,     0,        -pi/4;
       0,     pi/2,     0,    theta(10);
      -L(4),  pi/2,     0,    theta(11); 
      -L(5),     0,     0,   theta(12)];

% === 重心位置ベクトルの算出 ===

I = cell(6,1); 
for ii=1:6
    I{ii} = diag([Ixx(ii), Iyy(ii), Izz(ii)]);
end

num_links = size(DH1,1);
T1 = eye(4);
T2 = eye(4);
T3 = eye(4);

cg_links = [2,3,4,8,9,10];   % 重心を持つリンクの行番号
lg_map   = [1,2,3,4,5,6];    % lg1～lg6に対応づけ

r_c_list1 = sym([]); 
r_c_list2 = sym([]); 
r_c_list3 = sym([]);  

for i = 1:num_links
    % 各リンク変換行列
    A_i = DH2HTMat(DH1(i,:));
    T1 = T1 * A_i;

    % 指定されたリンク行のみ重心を計算
    if ismember(i, cg_links)
        idx = find(cg_links == i);
        lg_sym = lg(lg_map(idx));

        % リンク座標系の -x方向に lg_i
        r_local = [-lg_sym; 0; 0; 1];
        r_world = simplify(T1 * r_local);
        r_c_list1 = [r_c_list1, r_world(1:3)];
    end
end

for i = 1:num_links
    % 各リンク変換行列
    A_i = DH2HTMat(DH2(i,:));
    T2 = T2 * A_i;

    % 指定されたリンク行のみ重心を計算
    if ismember(i, cg_links)
        idx = find(cg_links == i);
        lg_sym = lg(lg_map(idx));

        % リンク座標系の -x方向に lg_i
        r_local = [-lg_sym; 0; 0; 1];
        r_world = simplify(T2 * r_local);
        r_c_list2 = [r_c_list2, r_world(1:3)];
    end
end

for i = 1:num_links
    % 各リンク変換行列
    A_i = DH2HTMat(DH3(i,:));
    T3 = T3 * A_i;

    % 指定されたリンク行のみ重心を計算
    if ismember(i, cg_links)
        idx = find(cg_links == i);
        lg_sym = lg(lg_map(idx));

        % リンク座標系の -x方向に lg_i
        r_local = [-lg_sym; 0; 0; 1];
        r_world = simplify(T3 * r_local);
        r_c_list3 = [r_c_list3, r_world(1:3)];
    end
end

%% --- 補助関数（Craig式DHからHT行列作成） ---
function A = DH2HTMat(dh_row)
    A = eye(4);
    a = dh_row(1);
    alpha = dh_row(2);
    d = dh_row(3);
    theta = dh_row(4);
    Tx = [1,         0,          0,  a;
          0,cos(alpha),-sin(alpha),  0;
          0,sin(alpha), cos(alpha),  0;
          0,         0,          0,  1];
    Tz = [cos(theta),-sin(theta), 0, 0;
          sin(theta), cos(theta), 0, 0;
                   0,          0, 1, d;
                   0,          0, 0, 1];
    A = A*Tx*Tz;
end