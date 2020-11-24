var blessed = require('blessed')
var contrib = require('blessed-contrib')
const Client = require('kubernetes-client').Client

// Getting a Kubernetes Client
const client = new Client({ version: '1.13' })

// Getting a blessed screen and setting escape key
var screen = blessed.screen()
screen.key(['escape', 'q', 'C-c'], function(ch, key) {
  return process.exit(0);
});

// Defining state variables
var pods_list = []

// Defining layout
var grid = new contrib.grid({rows: 3, cols: 3, screen: screen})

// Add a table with K8S pods and bring keyboard focus on it
var pods_table =  grid.set(1, 1, 2, 1, contrib.table, 
  { keys: true
  , fg: 'green'
  , label: 'List of Pods'
  , columnSpacing: 1
  , columnWidth: [10, 15, 40]
})
pods_table.focus()

// Add a log
var log_box = grid.set(1, 2, 2, 1, contrib.log, 
  { fg: "green"
  , selectedFg: "green"
  , label: 'Server Log'})

// Async functions declaration
async function fetch_pods() {
    // Fetch all the pods
    pods_list = []
    const pods = await client.api.v1.pods.get()
    pods.body.items.forEach((item) => {
        let pod_data = [item.status.phase, item.metadata.namespace, item.metadata.name]
        pods_list.push(pod_data)
    })
    //console.log(pods_list)
    pods_table.setData({headers: ['Status','Namespace','Pod'], data: pods_list})
    screen.render()
}

async function update_log(namespace, pod_name)
{
    // This will only work for pods with a single container running. 
    const log_response = await client.api.v1.namespaces(namespace).pods(pod_name).log.get()
    const log_content = log_response.body
    log_box.logLines = []
    log_box.log(log_content)
    screen.render()
}

// Event handling
pods_table.rows.on('select', function(row, idx){
    namespace = pods_list[idx][1]
    pod_name = pods_list[idx][2]
    update_log(namespace, pod_name)
})

// Periodic updates
setInterval(fetch_pods, 30000)

// Initial fetches
fetch_pods()

// Initial render
screen.render()