# Digital Clock

Reloj digital construido en ensamblador de PIC16F84A

## Requerimientos

- MPASMWIN, para compilar. Añadir su dirección al PATH de Windows para que `compile.bat` cumpla su función de forma adecuada (mejorando la eficiencia del flujo de trabajo)
- Proteus Professional (7.7 SP2)

## Workflow

Editar lo necesario en el archivo `Guzman_Bello.asm` y luego ejecutar

```bash
$ compile
```

Para compilar el archivo usando MPASMWIN.

Luego cargar el `.hex` en el PIC en Proteus
