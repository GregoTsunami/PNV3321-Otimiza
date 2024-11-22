function [d_max, x_traj, y_traj] = foguete_dist_max(m_agua, theta)
    % Parâmetros
    mg = 0.1; % MassaFoguete (kg)
    Vg = 0.003; % VolumeGarrafa (m^3)
    Ab = 7.85398e-5; % AreaBocal (m^2)
    Af = 7.853982e-3; % AreaFrontal (m^2)
    
    P = 300000; % PressaoLançamento (Pa)
    
    hr = 1; % AlturaRampa (m)
    rho_agua = 1000; % DensidadeAgua (kg/m^3)
    rho_ar = 1.4; % DensidadeAr (kg/m^3)
    Patm = 101325; % PressaoAtmosferica (Pa)
    Ca = 0.5; % CoefArrasto
    g = 9.8; % Gravidade (m/s^2)
    dt = 0.005; % PassoTempo (s)
    
    % Condições iniciais
    t_k = 0; % TempoInicial (s)
    d_k = 0.0; % DistXInicial (m)
    h_k = 0.0; % AlturaInicial (m)
    Ux_k = 0.1; % VelocidadeXInicial (m/s)
    Uy_k = 0.1; % VelocidadeYInicial (m/s)
    ax_k = 0.0; % AceleracaoXInicial (m/s^2)
    ay_k = 0.0; % AceleracaoYInicial (m/s^2)
    P_k = P; % PressaoInternaInicial (Pa)
    m_agua_k = m_agua; % MassaAguaInicial (kg)
    %theta_k = theta; %AnguloFoguete (°)

    % Plot do gráfico
    x_traj = []; % Trajetória em X
    y_traj = []; % Trajetória em Y
    
    % Simulação
    while h_k >= 0

        % Velocidade de água
        if P_k - Patm > 0
            U_agua_k = sqrt(2 * (P_k - Patm) / rho_agua);
        else
            U_agua_k = 0;
        end
        
        % Massa de água
        m_agua_k1 = m_agua_k;
        m_agua_k = max(m_agua_k - U_agua_k * Ab * rho_agua * dt, 0); % m_agua^(k-1)

        % Posições
        d_k = d_k + Ux_k * dt + 0.5 * ax_k * dt^2;
        h_k = h_k + Uy_k * dt + 0.5 * ay_k * dt^2;
        
        % Empuxo
        E_k = max((P_k - Patm) * Ab, 0);
        
        % Arrasto
        Fa_k = 0.5 * Ca * rho_ar * ((Ux_k)^2 + (Uy_k)^2) * Af;
        
        % Normal, Acelerações e Ângulo Foguete
        if (h_k < hr) && (d_k < hr / tan(theta)) && (Uy_k > 0)
            theta_k = theta*(pi/180);
            N_k = g * (mg + m_agua_k) * cos(theta_k);
            ax_k = ((E_k - Fa_k) * cos(theta_k) - N_k * sin(theta_k)) / (m_agua_k + mg);
            ay_k = ((E_k - Fa_k) * sin(theta_k) + N_k * cos(theta_k)) / (m_agua_k + mg) - g;
        else
            %N_k = 0;
            if Ux_k ~= 0
                theta_k = atan(Uy_k/Ux_k);
            else
                theta_k = theta*(pi/180);
            end
            ax_k = ((E_k - Fa_k) * cos(theta_k)) / (m_agua_k + mg);
            ay_k = ((E_k - Fa_k) * sin(theta_k)) / (m_agua_k + mg) - g;
        end
        
        % Velocidades
        if h_k >= 0
            Ux_k = Ux_k + ax_k*dt;
            Uy_k = Uy_k + ay_k*dt;
        else
            Ux_k = 0;
            Uy_k = 0;
        end

        % Pressão
        if m_agua_k > 0
            P_k1 = P_k;
            P_k = P_k1 * (Vg - m_agua_k1 / rho_agua) / (Vg - m_agua_k / rho_agua);
        else
            P_k = 0; % Após ejeção total da água, pressão igual à zero
        end

        if h_k >= 0
            x_traj = [x_traj, d_k];
            y_traj = [y_traj, h_k];
        end
        
        % Tempo
        t_k = t_k + dt;
    end

    
    % Distância Máxima Horizontal
    d_max = max(x_traj);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A)

% Chutes Iniciais
m_agua = 0.5; % Massa inicial de água (kg) 
theta = 45; % Ângulo da rampa (graus)

[d_max, x_traj, y_traj] = foguete_dist_max(m_agua, theta);
fprintf('A distância máxima horizontal é %.5f metros.\n', d_max);

% Plotar a trajetória
figure;
plot(x_traj, y_traj, 'b-', 'LineWidth', 1.5);
xlabel('Distância Horizontal (m)');
ylabel('Altura (m)');
title('Trajetória do Foguete');
grid on;

text(0.02*max(x_traj), 0.95*max(y_traj), ...
    sprintf('Massa água = %.3f kg\nÂngulo = %.2f°\nDistância = %.2f m', ...
    m_agua, theta, d_max), ...
    'FontSize', 10, 'BackgroundColor', 'white');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% B)

% Função Objetivo:
% Maximizar d_max(m_agua, theta)


% Variávveis e Restrições:
% m_agua: [0.1, 3.0] kg (0 < m_agua < rho_agua*Vg)
% theta: [0, 90] ° (0 < theta < 90°)
% P_k - Patm > 0 para ejetar


% Intervalo para Variáveis

m_agua_min = 0.1; % (kg)
m_agua_max = 2.9; % (kg)

theta_min = 10; % (°)
theta_max = 89; % (°)

m_agua_values = linspace(m_agua_min, m_agua_max, 100);
theta_values = deg2rad(linspace(theta_min, theta_max, 100));

% A partir daqui não sei o que ta acontecendo
% Função Objetivo
fobj_values = zeros(length(m_agua_values), length(theta_values), 'double');

for i = 1:length(m_agua_values)
    for j = 1:length(theta_values)
        fobj_values(i, j) = foguete_dist_max(m_agua_values(i), theta_values(j));
    end
end

% Verificação do máximo global
[max_dist, max_idx] = max(fobj_values(:));
[max_row, max_col] = ind2sub(size(fobj_values), max_idx);
fprintf('Máxima distância: %.2f m, com θ = %.2f° e massa = %.2f kg\n', ...
    max_dist, theta_values(max_col), m_agua_values(max_row));

% Plot 3D de theta x m_agua x Fobj
[Theta, M_agua] = meshgrid(theta_values, m_agua_values);
figure;
surf(Theta, M_agua, fobj_values);
xlabel('Ângulo \theta (graus)');
ylabel('Massa de água (kg)');
zlabel('Distância máxima (m)');
title('Distância máxima em função de \theta e massa de água');
colormap('jet');
colorbar;
shading interp;
view(135, 30);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% % Teste 1 -> meudeus
% [M, Theta] = meshgrid(m_agua_values, theta_values);
% fobj_values = zeros(size(M_agua, 1));
% for i = 1:size(M_agua, 1)
%    for j = 1:size(M_agua:2)
%        [fobj_values(i,j),~,~] = foguete_dist_max(M(i,j), Theta(i,j));
%    end
% end

% % Plotando o gráfico 3D
% figure;
% surf(M, Theta * 180 / pi, F_obj, 'EdgeColor', 'none'); % Theta em graus no gráfico
% colormap('jet');
% xlabel('Massa de Água (kg)');
% ylabel('Ângulo de Inclinação (°)');
% zlabel('Distância Máxima (m)');
% title('Campo de Soluções: Massa de Água x Ângulo x Distância');
% colorbar;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Teste 2 -> meudeus 2
% [M, Theta] = meshgrid(m_agua_values, theta_values);
% F_obj = zeros(size(M));
% for i = 1:size(M, 1)
%     for j = 1:size(M, 2)
%         F_obj(i, j) = foguete_dist_max(M(i, j), Theta(i, j));
%     end
% end

% % Plotando o gráfico 3D
% figure;
% surf(M, Theta * 180 / pi, F_obj, 'EdgeColor', 'none'); % Theta em graus no gráfico
% colormap('jet');
% xlabel('Massa de Água (kg)');
% ylabel('Ângulo de Inclinação (°)');
% zlabel('Distância Máxima (m)');
% title('Campo de Soluções: Massa de Água x Ângulo x Distância');
% colorbar;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Teste 3 - ;-;

% [M, Theta] = meshgrid(m_agua_values, theta_values);
% F_obj = zeros(size(M));

% for i = 1:size(M, 1)
%     for j = 1:size(M, 2)
%         [F_obj(i, j)] = foguete_dist_max(M(i, j), Theta(i, j));
%     end
% end

% % Plotando o gráfico 3D
% figure;
% surf(M, rad2deg(Theta), F_obj, 'EdgeColor', 'none');
% colormap('jet');
% xlabel('Massa de Água (kg)');
% ylabel('Ângulo de Inclinação (°)');
% zlabel('Distância Máxima (m)');
% title('Campo de Soluções: Massa de Água x Ângulo x Distância');
% colorbar;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% C)

% Com Fmincon
fobj = @(x) -foguete_dist_max(x(1), x(2));

% Restrições
lb = [m_agua_min, theta_min];
ub = [m_agua_max, theta_max];

% Ponto inicial arbitrário
x0 = [0.5, 45]; % m_agua = 0.5 kg, theta = 45 °

% Chamando o fmincon
options = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'sqp');
[x_opt, fval_opt] = fmincon(fobj, x0, [], [], [], [], lb, ub, [], options);

% Resultado da otimização
fprintf('Massa de água ótima: %.5f kg\n', x_opt(1));
fprintf('Ângulo ótimo: %.5f graus\n', x_opt(2));
fprintf('Distância máxima otimizada: %.5f m\n', -fval_opt);
grid on;

[d_max_opt, x_traj_opt, y_traj_opt] = foguete_dist_max(x_opt(1), x_opt(2));

% Gráfico da trajetória otimizada
figure;
plot(x_traj_opt, y_traj_opt, 'r-', 'LineWidth', 2);
xlabel('Distância Horizontal (m)');
ylabel('Altura (m)');
title('Trajetória Otimizada do Foguete');
grid on;

% Texto com as informações
text(0.02*max(x_traj_opt), 0.95*max(y_traj_opt), ...
    sprintf('Massa água = %.3f kg\nÂngulo = %.2f°\nDistância = %.2f m', ...
    x_opt(1), x_opt(2), d_max_opt), ...
    'FontSize', 10, 'BackgroundColor', 'white');