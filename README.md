# jenkins-slave-centos
<p><b>Steps to build a docker image</b></p>
<ul>
<li>Clone this repository by using git clone command</li>
<li>Make a files directory inside the root directory </li>
<li>Go to the jenkins master and then copy the id_rsa.pub as authorized_keys and then copy it over to the files directory , this authorized_keys is used to login into the docker container using ssh key as user jenkins form the jenkins master</li>
<li>You can use the username password credentials as well but I prefer going with username and SSH private key which is more secure</li>
<li>From the root directory where Dockerfile resides issue '<b>docker build -t &ltimage-name&gt .</b>'</li>
<li>The image will be built and it is now ready to be configured with the jenkins master.</li>
</ul>
