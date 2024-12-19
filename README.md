# TaskAI

Se realizo una app que realiza con una vista principal y dos fragmentos. La app inicia mostrando el primer fragmento, en en cual se puede ver un mapa que por defecto esta centrado en la ciudad de México. El segundo fragmento es para mostrar el historial de peticiones a una API. Para navegar entre los dos fragmentos  el usuario puede hacer uso de los botones “Show Map” y Show List. El tercer botón es para realizar los request a la API.

##Como base de datos se uso SQLite
##Para realizar las peticiones a la API se uso **URLSession**
##La arquitectura para la presentación de la información es **MVI**
##Para lograr el Unidirectional data flow se uso el framework **Observation**
