--Funcionamento do Relógio Pomodoro nos 4 display de 7 segmentos com o controle dos 5 botões: 
--Primeiro o usuário deverá colocar o tempo de sessão o qual deve aparecer nos diplays de 7 segmentos 1('1') E 2 ('-')
--e no display 3 (minutos a ser colocado pelo usuario com o botão de mais e menos) e no display 4('0' pois o tempo de sessão só se mexe nos minutos)
--Após colocar os minutos ele deve apertar enter para ir para a próxima etapa que é quantas sessões ele quer fazer
-- o display 1 ('2') e o display 2 ('-'), e no display 3('0' pois o numero de sessões varia na unidade) 
--no display 4(quantidade de 1 a 5 sessões o qual o usuário ira ajustar com o botao de + e -)
--Após colocar a quantidade de sessões ele deve apertar enter para ir para a próxima etapa que é o tempo de descanso
--o display 1('3') e o display 2 ('-'), e no display 3(minutos a ser colocado pelo usuario com o botão de mais e menos) e no display 4('0' pois o tempo de descanso só se mexe nos minutos)
--Após colocar os minutos ele deve apertar enter para ir para a próxima etapa que mostrará no display o tempo de sessão que o o usuário escolheu
--indicando que ja esta tudo pronto e o usuario pode apertar o botão de start para começar a contagem regressiva
--Deve mostrar no display 1(dezewna do minuto) 2(unidade do minuto) 3(dezena do segundo) 4(unidade do segundo)
--Quando o tempo de sessão acabar deve mostrar no display 1('0') 2('0') 3('0') 4('0') e começar a contagem regressiva do tempo de descanso
--Quando o tempo de descanso acabar deve mostrar no display 1('0') 2('0') 3('0') 4('0') e começar a contagem regressiva do tempo de sessão novamente
--assim, até que termine a quantidade das sessões escolhidas pelo usuário

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
-- Funcionamento:
--  O diplay 7 segmentos mostrará os valores 
--  de minutos e segundos. A contagem
--  será controlada pelos botões:--
--  KEY (5) : para a contagem (RESET)?????????

ENTITY PomodoroOFF IS
    GENERIC (
        DEBOUNCE : INTEGER := 2500000; -- filtro ruido de trepidaçao, 2500000*20ns = 50ms
        CICLES_SECOND : INTEGER := 50000000 -- Frequencia do clock em Hz
    );
    PORT (
        CLOCK_50MHz : IN STD_LOGIC;
        DISP0_D : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        DISP1_D : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        DISP2_D : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        DISP3_D : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        KEY : IN STD_LOGIC_VECTOR (4 DOWNTO 0)--?

    );
END PomodoroOFF;

ARCHITECTURE behavior OF PomodoroOFF IS

    SIGNAL rst : STD_LOGIC;
    SIGNAL key_ready : STD_LOGIC;
    SIGNAL key_data : STD_LOGIC_VECTOR (3 DOWNTO 0);
    SIGNAL var_seg : STD_LOGIC_VECTOR (7 DOWNTO 0);
	 signal key_int	: std_logic_vector (3 downto 0);
	 
 -- Declarações dos sinais
    SIGNAL state : INTEGER RANGE 0 TO 4; -- Estado atual
    SIGNAL session_time_setting, break_time_setting : INTEGER RANGE 0 TO 59; -- Configurações de tempo de sessão e intervalo
    SIGNAL session_count_setting, session_count : INTEGER RANGE 1 TO 5; -- Configurações e contagem de sessões
    SIGNAL session_timer, break_timer : INTEGER RANGE 0 TO CICLES_SECOND; -- Contadores para sessão e intervalo
	 SIGNAL min_high, min_low, sec_high, sec_low : STD_LOGIC_VECTOR(3 DOWNTO 0);
   
	-- Declaraçao do decodificador para display de 7 segmentos
    COMPONENT display_7seg IS
        PORT (
            data_i : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            disp_7seg_o : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)

        );
    END COMPONENT;
    -- Declaraçao do teclado
    COMPONENT Botao_base IS
        GENERIC (
            DEBOUNCE : INTEGER
        );
        PORT (
            clk_i : IN STD_LOGIC;
            push_button_i : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
            key_o : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            ready_o : OUT STD_LOGIC
        );
    END COMPONENT;

    -- Declaração sincronizador de reset
    COMPONENT reset_sync
        PORT (
            i_clk : IN STD_LOGIC;
            i_external_reset_n : IN STD_LOGIC;
            o_reset_n : OUT STD_LOGIC;
            o_reset : OUT STD_LOGIC
        );
    END COMPONENT;
begin
    --rst <= KEY(2);
    reset_synch_50mhz_inst : reset_sync
    PORT MAP(
       i_clk => CLOCK_50MHz,
       i_external_reset_n => KEY(2),
       o_reset => OPEN,
       o_reset_n => rst
    );

   

    -- Processo principal
    PROCESS (CLOCK_50MHz, rst)
        VARIABLE count : INTEGER RANGE 0 TO CICLES_SECOND := CICLES_SECOND; -- Contador para um segundo
        VARIABLE minutes, seconds : INTEGER RANGE 0 TO 59;
        --VARIABLE min_high, min_low, sec_high, sec_low : STD_LOGIC_VECTOR(3 DOWNTO 0);
			
    BEGIN
	 
        IF rst = '1' THEN
            -- Resetar todas as configurações e parar cronômetro (VOLTAR AO ESTADO INICIAL)
        ELSIF rising_edge(CLOCK_50MHz) THEN
            CASE state IS
                WHEN 0 =>

                    IF key_ready = '1' THEN
                        CASE key_int IS
                            WHEN "0001" => --"0001" código para o botão Mais
                                IF session_time_setting <= 60 THEN
                                    session_time_setting <= session_time_setting + 1;
                                END IF;
                            WHEN "0010" => -- "0010" código para o botão Menos
                                IF session_time_setting > 0 THEN
                                    session_time_setting <= session_time_setting - 1;
                                END IF;
                            WHEN "0011" => --  "0011" código para o botão Enter
                                state <= 1; -- Mudar para o próximo estado
                            WHEN OTHERS =>
                                NULL; -- Nenhuma ação para outros códigos; Em um case ou select statement, é uma boa prática incluir when others para garantir que todos os possíveis valores de entrada sejam considerados, especialmente quando se lida com sinais ou variáveis de largura de bit fixa. Isso ajuda a prevenir comportamentos imprevisíveis ou não definidos.
                        END CASE;
                    END IF;

                WHEN 1 =>
                    -- Lógica para configurar o número de sessões
                    IF key_ready = '1' THEN
                        CASE key_int IS
                            WHEN "0001" =>
                                IF session_count_setting < 5 THEN -- Supondo um máximo de 5 sessões
                                    session_count_setting <= session_count_setting + 1;
                                END IF;
                            WHEN "0010" =>
                                IF session_count_setting > 1 THEN --  mínimo de 1 sessão
                                    session_count_setting <= session_count_setting - 1;
                                END IF;
                            WHEN "0011" =>
                                state <= 2; -- Mudar para o próximo estado
                            WHEN OTHERS =>
                                NULL; -- Nenhuma ação para outros códigos
                        END CASE;
                    END IF;
                WHEN 2 =>
                    -- Lógica para configurar o tempo de intervalo
                    IF key_ready = '1' THEN
                        CASE key_int IS
                            WHEN "0001" =>
                                IF break_time_setting <= 60 THEN
                                    break_time_setting <= break_time_setting + 1;
                                END IF;
                            WHEN "0010" =>
                                IF break_time_setting > 0 THEN
                                    break_time_setting <= break_time_setting - 1;
                                END IF;
                            WHEN "0100" => -- Código para o botão Start
                                session_timer <= session_time_setting; -- Inicializar o contador da sessão com o tempo definido (*60)
                                session_count <= session_count_setting; -- Inicializar o contador de sessões com o número definido
                                break_timer <= break_time_setting; -- Inicializar o contador do intervalo com o tempo definido (*60)
                                state <= 3; -- Mudar para o estado da contagem regressiva da sessão
                            WHEN OTHERS =>
                                NULL; -- Nenhuma ação para outros códigos
                        END CASE;
                    END IF;

                WHEN 3 =>
                    -- Lógica para a contagem regressiva da sessão
                    IF session_timer > 0 THEN
                        count := count - 1;
                        IF count = 0 THEN
                            count := CICLES_SECOND;
                            session_timer <= session_timer - 1; -- Decrementar o contador da sessão

                            -- Converter o tempo para minutos e segundos
                            minutes := session_timer / 60;
                            seconds := session_timer MOD 60; -- mod é o operador de módulo

                            -- Separar os dígitos dos minutos e segundos
                            min_high <= STD_LOGIC_VECTOR(to_unsigned(minutes / 10, 4)); -- to_unsigned converte um inteiro para um vetor de bits
                            min_low <= STD_LOGIC_VECTOR(to_unsigned(minutes MOD 10, 4)); -- std_logic_vector converte um vetor de bits para um vetor de bits
                            sec_high <= STD_LOGIC_VECTOR(to_unsigned(seconds / 10, 4));
                            sec_low <= STD_LOGIC_VECTOR(to_unsigned(seconds MOD 10, 4));

                            -- Atualizar os displays
                            DISP0_D <= disp_7seg(min_high) ; -- Display para dezena dos minutos
                            DISP1_D <= min_low; -- Display para unidade dos minutos
                            DISP2_D <= sec_high; -- Display para dezena dos segundos
                            DISP3_D <= sec_low; -- Display para unidade dos segundos
                        END IF;
                    ELSE
                        state <= 4; -- Mudar para o estado do intervalo

                    END IF;
                WHEN 4 =>
                    IF break_timer > 0 THEN
                        count := count - 1;
                        IF count = 0 THEN
                            count := CICLES_SECOND;
                            break_timer <= break_timer - 1; -- Decrementar o contador do intervalo

                            -- Converter o tempo para minutos e segundos
                            minutes := break_timer / 60;
                            seconds := break_timer MOD 60;
									 

                            -- Separar os dígitos dos minutos e segundos
                            min_high <= STD_LOGIC_VECTOR(to_unsigned(minutes / 10, 4));
                            min_low <= STD_LOGIC_VECTOR(to_unsigned(minutes MOD 10, 4));
                            sec_high <= STD_LOGIC_VECTOR(to_unsigned(seconds / 10, 4));
                            sec_low <= STD_LOGIC_VECTOR(to_unsigned(seconds MOD 10, 4));
                            -- Atualizar os displays
                            DISP0_D <= min_high; -- Display para dezena dos minutos
                            DISP1_D <= min_low; -- Display para unidade dos minutos
                            DISP2_D <= sec_high; -- Display para dezena dos segundos
                            DISP3_D <= sec_low; -- Display para unidade dos segundos

                        END IF;
                    ELSE
                        -- zerar tudo e voltar ao estado inicial
                        state <= 0;
                    END IF;
                WHEN OTHERS =>
                    NULL;
            END CASE;
        END IF;
    END PROCESS;

    -- Display de 7 segmentos da dezena dos minutos
	conversor_7seg_1:
	display_7seg 
	port map
	(
		data_i		=> min_high(3 downto 0),
		disp_7seg_o	=> DISP0_D (6 downto 0)
	);
	
	
	-- Display de 7 segmentos da unidade dos minutos
	conversor_7seg_2:
	display_7seg 
	port map
	(
		data_i		=> min_low(3 downto 0),
		disp_7seg_o	=> DISP1_D(6 downto 0)
	);
	

    -- Display de 7 segmentos da dezena dos segundos
	conversor_7seg_3:
	display_7seg 
	port map
	(
		data_i		=> sec_high(3 downto 0),
		disp_7seg_o	=> DISP2_D(6 downto 0)
	);
	
	
	-- Display de 7 segmentos da unidades dos segundos
	conversor_7seg_4:
	display_7seg 
	port map
	(
		data_i		=> sec_low(3 downto 0),
		disp_7seg_o	=> DISP3_D(6 downto 0)
	);
	

    --instanciacao do botao
    botao_inst : Botao_base

    GENERIC MAP (
        DEBOUNCE => DEBOUNCE
    )
    PORT MAP (
        clk_i => CLOCK_50MHz,
        push_button_i => KEY,
        key_o => key_data,
        ready_o => key_ready
    );

    end behavior;