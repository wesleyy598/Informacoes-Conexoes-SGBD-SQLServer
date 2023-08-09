SELECT
		p.spid AS Processo,
		t.text AS ComandoSQL,
		OBJECT_NAME(t.objectid, DB_ID()) AS NomeObjeto, -- Adiciona o nome da view/procedure
		r.start_time AS HoraInicio,
		CONVERT(VARCHAR(10), DATEADD(ms, DATEDIFF(ms, p.last_batch, GETDATE()), '1900-01-01'), 108) AS TempoProcesso,
		p.hostname AS Computador,
		DB_NAME(r.database_id) AS BancoDados,
		p.loginame AS Usuario,
		p.status AS Status,
		r.status AS StatusComando,
		p.blocked AS BloqueadoPor,
		p.cmd AS TipoComando,
		p.program_name AS Aplicativo,
		r.reads AS Leituras,
		r.writes AS Escritas,
		r.logical_reads AS LeiturasLogicas,
		c.client_net_address AS EnderecoIP, -- Adiciona o endereço IP da conexão
		c.local_tcp_port AS PortaConexao -- Adiciona a porta da conexão
FROM	master..sysprocesses AS p
		LEFT JOIN sys.dm_exec_requests AS r ON p.spid = r.session_id
		OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
		LEFT JOIN sys.dm_exec_sessions AS s ON r.session_id = s.session_id
		LEFT JOIN sys.dm_exec_connections AS c ON s.session_id = c.session_id
WHERE	p.status IN ('runnable', 'suspended')
		AND p.spid != @@SPID
