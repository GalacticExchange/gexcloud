
# download
# !!! download manually
cd /vagrant
wget http://download.oracle.com/otn-pub/java/jdk/8u65-b17/jdk-8u65-linux-x64.tar.gz


#
sudo mkdir -p /usr/local/java


cd /vagrant

sudo cp -r jdk-8u65-linux-x64.tar.gz  /usr/local/java/


cd /usr/local/java/

sudo tar -zxvf  jdk-8u65-linux-x64.tar.gz


# After extraction you must see a folder named jdk1.8.0_51.

# edit /etc/profile
#sudo nano /etc/profile

# paste the following at the end of the file:
cat >> /etc/profile <<EOT

JAVA_HOME=/usr/local/java/jdk1.8.0_65
PATH=$PATH:$HOME/bin:$JAVA_HOME/bin
export JAVA_HOME
export PATH

EOT




# Tell the system that the new Oracle Java version is available by the following commands:
sudo update-alternatives --install "/usr/bin/java" "java" "/usr/local/java/jdk1.8.0_65/bin/java" 1
sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/local/java/jdk1.8.0_65/bin/javac" 1
sudo update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/local/java/jdk1.8.0_65/bin/javaws" 1

# Make Oracle Java JDK as default:
sudo update-alternatives --set java /usr/local/java/jdk1.8.0_65/bin/java
sudo update-alternatives --set javac /usr/local/java/jdk1.8.0_65/bin/javac
sudo update-alternatives --set javaws /usr/local/java/jdk1.8.0_65/bin/javaws


# Reload system wide PATH /etc/profile
source /etc/profile

# Reboot your system.


# Check Java JDK version by

#java -version

# If installation is successful, it will display like the following:

#java version "1.8.0_65"
#Java(TM) SE Runtime Environment (build 1.8.0_65-b17)
#Java HotSpot(TM) 64-Bit Server VM (build 25.65-b01, mixed mode)
