injection is typically enabled by annotating with the @Value annotation (to inject into a single field) or the @ConfigurationProperties annotation (to inject into multiple properties on a Java bean class).

The reload feature of Spring Cloud Kubernetes is able to trigger an application reload when a related ConfigMap or Secret change.

only configuration beans annotated with @ConfigurationProperties or @RefreshScope are reloaded. This reload level leverages the refresh feature of Spring Cloud Context.

. A configuration properties bean is a Java bean decorated by the @Configuration and @ConfigurationProperties annotations.

The @Configuration annotation causes the QuickstartConfiguration class to be instantiated and registered in Spring as the bean with ID, quickstartConfiguration. This automatically makes the bean accessible from Camel. For example, the target-route-queue route is able to access the queueUserName property using the Camel syntax ${bean:quickstartConfiguration?method=getQueueUsername}.

the Spring Cloud Kubernetes plug-in must be configured with the mount paths of the Secrets, so that it can read the Secrets at run time.

requires you to match the ConfigMap’s metadata.name with the value of the spring.application.name property configured in the project’s bootstrap.yml file.

spring.cloud.kubernetes.secrets.enabled
Enable the Secrets property source. Type is Boolean and default is true.
spring.cloud.kubernetes.secrets.name
Sets the name of the secret to look up. Type is String and default is ${spring.application.name}.
spring.cloud.kubernetes.secrets.labels
Sets the labels used to lookup secrets. This property behaves as defined by Map-based binding. Type is java.util.Map and default is null.
spring.cloud.kubernetes.secrets.paths
Sets the paths where secrets are mounted. This property behaves as defined by Collection-based binding. Type is java.util.List and default is null.
spring.cloud.kubernetes.secrets.enableApi
Enable/disable consuming secrets via APIs. Type is Boolean and default is false.


spring.cloud.kubernetes.reload.enabled=true

```
@Component
public class MyBean {

    @Autowired
    private MyConfig config;

    @Scheduled(fixedDelay = 5000)
    public void hello() {
        System.out.println("The message is: " + config.getMessage());
    }
}
```

This discovery feature is also used by the Spring Cloud Kubernetes Ribbon or Zipkin projects to fetch respectively the list of the endpoints defined for an application to be load balanced or the Zipkin servers available to send the traces or spans.

Some Spring Cloud components use the DiscoveryClient in order to obtain info about the local service instance. For this to work you need to align the service name with the spring.application.name property.

The default behavior is to create a ConfigMapPropertySource based on a Kubernetes ConfigMap which has metadata.name of either the name of your Spring application (as defined by its spring.application.name property) or a custom name defined within the bootstrap.properties file under the following key spring.cloud.kubernetes.config.name.

refresh (default): only configuration beans annotated with @ConfigurationProperties or @RefreshScope are reloaded. This reload level leverages the refresh feature of Spring Cloud Context.

When the application runs as a pod inside Kubernetes a Spring profile named kubernetes will automatically get activated. This allows the developer to customize the configuration, to define beans that will be applied when the Spring Boot application is deployed within the Kubernetes platform (e.g. different dev and prod configuration).
