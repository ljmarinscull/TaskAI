# TaskAI

Se realizó una app que cuenta con una vista principal y dos fragmentos. La app inicia mostrando el primer fragmento, en en cual se puede ver un mapa. El mapa esta centrado en la ciudad de México por defecto. El segundo fragmento es para mostrar el historial de peticiones realizadas a una API dada en el ejercicio. Para navegar entre los dos fragmentos el usuario puede hacer uso de los botones **Show Map** y **Show List**. El tercer botón es para realizar los request a la API.

- Como base de datos se usó **SQLite**
- Para realizar las peticiones a la API se usó **URLSession**
- La arquitectura para la presentación de la información utilizada es **MVI**
- Para lograr el comunicacion del **Model** con la **View** se uso el framework **Observation**
