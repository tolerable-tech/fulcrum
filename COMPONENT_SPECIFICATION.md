So WIP, annotated specification for components.

it is a JSON object. Each thing in this list is a top level property.

* *spec_version*    (R) The version of this specification used by this specification.
* *name*:           (R) The name of your component. Used in searching and in container naming.
* *description*:    (R) A description for people of what your component does.
* *version*:        (R) What version of your component this is for.
* *webpage*:        (O) A webpage with information about your component.
* *metadata_url*:   (R) the URL that the component speicifation is available at.
* *image_url*:      (R) The URL where the docker image is available for download. can also be a name where it can be found on a docker registry.
* *discovery_url*:  (R) A URL that your component will accept HTTP GET requests and tell Fulcrum more about its capabilities.
* *provides*:       (O) A list of Fulcrum Services that your component will provide.
* *publishes*:      (O) A list of things that your component makes available to Fulcrum. Ports, or DNS settings, or notifications.
* *dependencies*:   (O) A list of other ocmponents that your component requires to operate.
* *requires*:       (O) A list of things that your component requires to run. Generated ENV vars / Configurations etc.
* *configurables*:  (O) A list of objects that a Fulcrum owner is able to configure
                        in your component. When these are changed your component
                        will be notified in the manner specified in the
                        *discovery_url* response. A `type` property can be used
                        to specify a type other than string (only one currently
                        supported). A property `generable`, if set to true will
                        cause Fulcrum to generate random value if one is not set by
                        the owner. Supply a default in the `default`. The
                        property `export_as` tells Fulcrum to use this value in
                        predefined ways, such as a `hostname` that your component
                        would like to listen on, and that corresponds to a DNS
                        thing..
* *accompaniments*: (O) A list of Fulcrum Accompaniments that your component is requesting.

