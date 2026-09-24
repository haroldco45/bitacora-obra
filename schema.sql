/* =====================================================================
   Bitácora de Obra Pro — Esquema SQL Server (Fase 2: multiusuario)
   Desarrollada por Vibras Positivas HM — Derechos de Autor Reservados
   Backend previsto: Node.js + Express + mssql, administrado con PM2.
   Todas las fechas y horas se guardan en hora Colombia (UTC-5) con
   DATETIMEOFFSET para no perder la zona.
   ===================================================================== */

CREATE TABLE Empresas (            -- cada contratista o interventoría cliente
  EmpresaId       INT IDENTITY PRIMARY KEY,
  RazonSocial     NVARCHAR(200) NOT NULL,
  Nit             VARCHAR(20)   NOT NULL UNIQUE,
  Plan            VARCHAR(20)   NOT NULL DEFAULT 'basico',
  Activa          BIT           NOT NULL DEFAULT 1,
  CreadoEn        DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
);

CREATE TABLE Usuarios (
  UsuarioId       INT IDENTITY PRIMARY KEY,
  EmpresaId       INT NOT NULL REFERENCES Empresas(EmpresaId),
  Nombre          NVARCHAR(150) NOT NULL,
  Correo          NVARCHAR(150) NOT NULL UNIQUE,
  Celular         VARCHAR(20)   NULL,          -- dato sensible: se enmascara en la API
  Matricula       VARCHAR(40)   NULL,          -- COPNIA / CPNAA
  Rol             VARCHAR(20)   NOT NULL CHECK (Rol IN ('admin','director','residente','interventor','supervisor','consulta')),
  HashClave       VARCHAR(255)  NOT NULL,      -- bcrypt
  Activo          BIT NOT NULL DEFAULT 1
);

CREATE TABLE Contratos (
  ContratoId      INT IDENTITY PRIMARY KEY,
  EmpresaId       INT NOT NULL REFERENCES Empresas(EmpresaId),
  Numero          NVARCHAR(120) NOT NULL,
  Objeto          NVARCHAR(MAX) NOT NULL,
  Alcance         NVARCHAR(MAX) NULL,
  Entidad         NVARCHAR(200) NOT NULL,
  NitEntidad      VARCHAR(20)   NULL,
  Contratista     NVARCHAR(200) NOT NULL,
  NitContratista  VARCHAR(20)   NULL,
  Interventoria   NVARCHAR(200) NULL,
  Supervisor      NVARCHAR(150) NULL,
  Lugar           NVARCHAR(200) NULL,
  Valor           DECIMAL(18,2) NOT NULL,
  PlazoMeses      INT NOT NULL DEFAULT 0,
  PlazoDias       INT NOT NULL DEFAULT 0,
  FechaFirma      DATE NULL,
  FechaInicio     DATE NULL,
  UrlSecop        NVARCHAR(400) NULL,
  PortalPublico   BIT NOT NULL DEFAULT 0       -- avance visible a la comunidad
);

CREATE TABLE ContratoUsuarios (    -- quién trabaja en qué obra y con qué rol
  ContratoId      INT NOT NULL REFERENCES Contratos(ContratoId),
  UsuarioId       INT NOT NULL REFERENCES Usuarios(UsuarioId),
  Rol             VARCHAR(20) NOT NULL,
  PRIMARY KEY (ContratoId, UsuarioId)
);

CREATE TABLE Eventos (             -- actas de suspensión, reanudación, prórroga, adición
  EventoId        INT IDENTITY PRIMARY KEY,
  ContratoId      INT NOT NULL REFERENCES Contratos(ContratoId),
  Tipo            VARCHAR(20) NOT NULL CHECK (Tipo IN ('suspension','prorroga','adicion')),
  Desde           DATE NULL,
  Hasta           DATE NULL,
  Meses           INT NULL,
  Dias            INT NULL,
  ValorAdicion    DECIMAL(18,2) NULL,
  Soporte         NVARCHAR(250) NOT NULL,
  Motivo          NVARCHAR(MAX) NULL,
  ArchivoUrl      NVARCHAR(400) NULL,          -- PDF del acta firmada
  RegistradoPor   INT NOT NULL REFERENCES Usuarios(UsuarioId),
  RegistradoEn    DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
);

CREATE TABLE Polizas (
  PolizaId        INT IDENTITY PRIMARY KEY,
  ContratoId      INT NOT NULL REFERENCES Contratos(ContratoId),
  Amparo          NVARCHAR(150) NOT NULL,
  Aseguradora     NVARCHAR(150) NULL,
  Numero          VARCHAR(60) NULL,
  ValorAsegurado  DECIMAL(18,2) NULL,
  VigenteHasta    DATE NULL,
  Regla           VARCHAR(20) NULL CHECK (Regla IN ('plazo','plazo+4m','recibo+5a'))
);

CREATE TABLE Items (               -- presupuesto oficial
  ItemId          INT IDENTITY PRIMARY KEY,
  ContratoId      INT NOT NULL REFERENCES Contratos(ContratoId),
  Codigo          VARCHAR(30) NOT NULL,
  Descripcion     NVARCHAR(300) NOT NULL,
  Unidad          VARCHAR(15) NOT NULL,
  Cantidad        DECIMAL(18,4) NOT NULL,
  ValorUnitario   DECIMAL(18,2) NOT NULL,
  UNIQUE (ContratoId, Codigo)
);

CREATE TABLE Folios (              -- bitácora: inmutable después del cierre
  FolioId         INT IDENTITY PRIMARY KEY,
  ContratoId      INT NOT NULL REFERENCES Contratos(ContratoId),
  Numero          INT NOT NULL,
  Fecha           DATE NOT NULL,
  Clima           VARCHAR(30) NULL,
  HorasPerdidas   DECIMAL(4,1) NOT NULL DEFAULT 0,
  Profesionales   INT NOT NULL DEFAULT 0,
  Oficiales       INT NOT NULL DEFAULT 0,
  Ayudantes       INT NOT NULL DEFAULT 0,
  Operadores      INT NOT NULL DEFAULT 0,
  Equipos         NVARCHAR(500) NULL,
  Actividades     NVARCHAR(MAX) NOT NULL,
  Observaciones   NVARCHAR(MAX) NULL,
  Latitud         DECIMAL(9,6) NULL,
  Longitud        DECIMAL(9,6) NULL,
  Estado          VARCHAR(10) NOT NULL DEFAULT 'borrador' CHECK (Estado IN ('borrador','cerrado')),
  ResidenteId     INT NULL REFERENCES Usuarios(UsuarioId),
  FirmaResidente  NVARCHAR(MAX) NULL,          -- PNG base64
  CerradoEn       DATETIMEOFFSET NULL,
  HashAnterior    CHAR(64) NULL,
  Hash            CHAR(64) NULL,               -- SHA-256 del contenido + HashAnterior
  UNIQUE (ContratoId, Numero)
);

CREATE TABLE FolioCantidades (
  FolioId         INT NOT NULL REFERENCES Folios(FolioId),
  ItemId          INT NOT NULL REFERENCES Items(ItemId),
  Cantidad        DECIMAL(18,4) NOT NULL CHECK (Cantidad >= 0),
  PRIMARY KEY (FolioId, ItemId)
);

CREATE TABLE FolioFotos (
  FotoId          INT IDENTITY PRIMARY KEY,
  FolioId         INT NOT NULL REFERENCES Folios(FolioId),
  Url             NVARCHAR(400) NOT NULL,      -- archivo en disco del servidor, no en la base
  Sha256          CHAR(64) NOT NULL
);

CREATE TABLE VistosBuenos (
  FolioId         INT PRIMARY KEY REFERENCES Folios(FolioId),
  InterventorId   INT NOT NULL REFERENCES Usuarios(UsuarioId),
  Firma           NVARCHAR(MAX) NOT NULL,
  FirmadoEn       DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET(),
  Hash            CHAR(64) NOT NULL
);

CREATE TABLE Anotaciones (
  AnotacionId     INT IDENTITY PRIMARY KEY,
  FolioId         INT NOT NULL REFERENCES Folios(FolioId),
  AutorId         INT NOT NULL REFERENCES Usuarios(UsuarioId),
  Texto           NVARCHAR(MAX) NOT NULL,
  CreadoEn        DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
);

CREATE TABLE Obligaciones (
  ObligacionId    INT IDENTITY PRIMARY KEY,
  ContratoId      INT NOT NULL REFERENCES Contratos(ContratoId),
  Texto           NVARCHAR(500) NOT NULL,
  Periodicidad    VARCHAR(10) NOT NULL CHECK (Periodicidad IN ('unica','diaria','semanal','mensual','pago')),
  Fuente          NVARCHAR(150) NULL
);

CREATE TABLE Cumplimientos (
  CumplimientoId  INT IDENTITY PRIMARY KEY,
  ObligacionId    INT NOT NULL REFERENCES Obligaciones(ObligacionId),
  Fecha           DATE NOT NULL,
  Soporte         NVARCHAR(300) NULL,
  ArchivoUrl      NVARCHAR(400) NULL,
  RegistradoPor   INT NOT NULL REFERENCES Usuarios(UsuarioId)
);

CREATE TABLE PQR (
  PqrId           INT IDENTITY PRIMARY KEY,
  ContratoId      INT NOT NULL REFERENCES Contratos(ContratoId),
  Radicado        VARCHAR(20) NOT NULL,
  Fecha           DATE NOT NULL,
  Tipo            VARCHAR(30) NOT NULL,
  Nombre          NVARCHAR(150) NOT NULL,
  Telefono        VARCHAR(20) NULL,            -- sensible (Ley 1581): se enmascara salvo rol admin
  Direccion       NVARCHAR(200) NULL,
  Descripcion     NVARCHAR(MAX) NOT NULL,
  AutorizaDatos   BIT NOT NULL,
  Canal           VARCHAR(20) NOT NULL DEFAULT 'presencial',  -- presencial | qr_valla
  Estado          VARCHAR(12) NOT NULL DEFAULT 'abierta',
  Respuesta       NVARCHAR(MAX) NULL,
  FechaRespuesta  DATE NULL,
  UNIQUE (ContratoId, Radicado)
);

CREATE TABLE Auditoria (           -- toda escritura queda registrada
  AuditoriaId     BIGINT IDENTITY PRIMARY KEY,
  UsuarioId       INT NULL,
  Tabla           VARCHAR(40) NOT NULL,
  RegistroId      INT NOT NULL,
  Accion          VARCHAR(10) NOT NULL,
  Detalle         NVARCHAR(MAX) NULL,
  Ip              VARCHAR(45) NULL,
  Fecha           DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIMEOFFSET()
);
GO

/* Un folio cerrado no se puede modificar ni borrar */
CREATE TRIGGER trg_Folios_Inmutables ON Folios
AFTER UPDATE, DELETE AS
BEGIN
  SET NOCOUNT ON;
  IF EXISTS (SELECT 1 FROM deleted WHERE Estado = 'cerrado')
  BEGIN
    RAISERROR('Un folio cerrado no se puede modificar ni eliminar. Use una anotación.', 16, 1);
    ROLLBACK TRANSACTION;
  END
END;
GO
