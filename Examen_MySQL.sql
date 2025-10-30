CREATE TABLE IF NOT EXISTS Auditoria_Clientes (
  id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT NOT NULL,
  campo_modificado ENUM('NONE','EMAIL','DIRECCION_DE_ENVIO') DEFAULT 'NONE',
  valor_antiguo VARCHAR(255),
  valor_nuevo VARCHAR(255),
  fecha_modificacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
);

DROP TRIGGER IF EXISTS trg_audit_cliente_after_update;
DELIMITER //
CREATE TRIGGER trg_audit_cliente_after_update
AFTER INSERT ON Auditoria_Clientes
FOR EACH ROW
BEGIN

    IF NEW.campo_modificado = 'EMAIL' THEN
        UPDATE Clientes
        SET email = NEW.valor_nuevo
        WHERE id_cliente = NEW.id_cliente;
    END IF;
    
    IF NEW.campo_modificado = 'DIRECCION_DE_ENVIO' THEN
        UPDATE Clientes
        SET direccion_envio = NEW.valor_nuevo
        WHERE id_cliente = NEW.id_cliente;
    END IF;
END//
DELIMITER ;

INSERT INTO Auditoria_Clientes (id_cliente, campo_modificado, valor_antiguo, valor_nuevo) VALUES
(1, 'EMAIL', 'laura.garcia@email.com', 'laura.gabriela.garcia@email.com');

-- INTENTO FALLIDO DE AUMENTAR CONDICIONES

-- DROP TRIGGER IF EXISTS trg_audit_cliente_after_update;
-- DELIMITER //
-- CREATE TRIGGER trg_audit_cliente_after_update
-- AFTER INSERT ON Auditoria_Clientes
-- FOR EACH ROW
-- BEGIN

--     IF NEW.campo_modificado = 'EMAIL' AND NEW.valor_antiguo = email THEN
--         UPDATE Clientes
--         SET email = NEW.valor_nuevo
--         WHERE id_cliente = NEW.id_cliente;
--     END IF;
    
--     IF NEW.campo_modificado = 'DIRECCION_DE_ENVIO' AND NEW.valor_antiguo = direccion_envio THEN
--         UPDATE Clientes
--         SET direccion_envio = NEW.valor_nuevo
--         WHERE id_cliente = NEW.id_cliente;
--     END IF;
-- END//
-- DELIMITER ;
