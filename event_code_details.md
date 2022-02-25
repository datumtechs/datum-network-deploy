[TOC]

## Data node related

| event code |                      detail                       |
| :--------: | :-----------------------------------------------: |
|  0209000   |                 start a new task                  |
|  0209001   |        Download contract code successfully        |
|  0209002   |         Failed to download contract code          |
|  0209003   | Build the computing task environment successfully |
|  0209004   |     Failed to build compute task environment      |
|  0209005   |        Create network channel successfully        |
|  0209006   |         Failed to create network channel          |
|  0209007   |      Successful registration to via service       |
|  0209008   |         Failed to register to via service         |
|  0209009   |        Set up network channel successfully        |
|  0209010   |           Failed to set network channel           |
|  0209011   |           Start executing the contract            |
|  0209012   |      The contract was executed successfully       |
|  0209013   |             Contract execution failed             |
|  0209014   |      Failed to use resource exceeding limit       |

## Compute node related
| event code |                      detail                       |
| :--------: | :-----------------------------------------------: |
|  0309000   |                 start a new task                  |
|  0309001   |        Download contract code successfully        |
|  0309002   |         Failed to download contract code          |
|  0309003   | Build the computing task environment successfully |
|  0309004   |     Failed to build compute task environment      |
|  0309005   |        Create network channel successfully        |
|  0309006   |         Failed to create network channel          |
|  0309007   |      Successful registration to via service       |
|  0309008   |         Failed to register to via service         |
|  0309009   |        Set up network channel successfully        |
|  0309010   |           Failed to set network channel           |
|  0309011   |           Start executing the contract            |
|  0309012   |      The contract was executed successfully       |
|  0309013   |             Contract execution failed             |
|  0309014   |      Failed to use resource exceeding limit       |

## Data is shared with computing nodes

| event code |                            detail                            |
| :--------: | :----------------------------------------------------------: |
|  0008000   | Success terminator, success terminator, this event will only be generated by a data node or a compute node when it finally runs successfully |
|  0008001   | Failure terminator, this event will be generated if any data node or compute node fails to run |
