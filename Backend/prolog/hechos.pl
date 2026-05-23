:- module(hechos, [jugador/1, artefactosLogrados/1, modulo/2, artefacto/2, enlace/2, necesita/2, pasoPrevio/2]).
:- dynamic jugador/1.
:- dynamic artefactosLogrados/1.

% Ejemplo de hechos
% Modulos
modulo(puente_mando, "Centro principal de la estacion.").
modulo(laboratorio, "Laboratorio cientifico parcialmente destruido.").
modulo(modulo_energia, "Modulo encargado del suministro energetico.").
modulo(enfermeria, "Area medica de emergencia.").
modulo(modulo_escape, "Zona de evacuacion orbital.").
% Enlaces
enlace(puente_mando, laboratorio).
enlace(laboratorio, modulo_energia).
enlace(puente_mando, enfermeria).
enlace(enfermeria, modulo_escape).
% Artefactos
artefacto(traje_espacial, enfermeria).
artefacto(fusible, laboratorio).
artefacto(tarjeta_seguridad, puente_mando).
% Sistemas
sistema(modulo_energia,energia,[fusible],fallo).
sistema(laboratorio,comunicaciones,[ fusible ,traje_espacial],fallo).
% Tripulantes
tripulante(elena, modulo_energia, [energia], atrapado).
tripulante(kai, enfermeria, [energia], atrapado).
% Restricciones de acceso
necesita(modulo_energia, traje_espacial).
necesita(modulo_escape, tarjeta_seguridad).
% Restricciones de estado
necesitaEstado(modulo_escape, energia, restaurado).
% Restricciones por pasos previos
pasoPrevio(modulo_escape, modulo_energia).
% condiciones de gane
objetivoS(energia, restaurado).
objetivoS(comunicaciones, restaurado).
objetivoT(elena, rescatado).
% Estado inicial
jugador(puente_mando).
artefactosLogrados([]).