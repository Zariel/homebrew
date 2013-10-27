require 'formula'

class Thrift < Formula
  homepage 'http://thrift.apache.org'
  url 'http://www.apache.org/dyn/closer.cgi?path=thrift/0.9.1/thrift-0.9.1.tar.gz'
  sha1 'dc54a54f8dc706ffddcd3e8c6cd5301c931af1cc'

  head do
    url 'https://git-wip-us.apache.org/repos/asf/thrift.git', :branch => "master"

    depends_on :autoconf
    depends_on :automake
    depends_on :libtool
  end

  option "with-haskell", "Install Haskell binding"
  option "with-erlang", "Install Erlang binding"
  option "with-java", "Install Java binding"
  option "with-perl", "Install Perl binding"
  option "with-php", "Install Php binding"

  depends_on 'boost'
  depends_on :python => :optional

  # Includes are fixed in the upstream. Please remove this patch in the next version > 0.9.0
  def patches
    DATA
  end

  def install
    system "./bootstrap.sh" if build.head?

    exclusions = ["--without-ruby"]

    exclusions << "--without-python" unless build.with? "python"
    exclusions << "--without-haskell" unless build.include? "with-haskell"
    exclusions << "--without-java" unless build.include? "with-java"
    exclusions << "--without-perl" unless build.include? "with-perl"
    exclusions << "--without-php" unless build.include? "with-php"
    exclusions << "--without-erlang" unless build.include? "with-erlang"

    ENV["PY_PREFIX"] = prefix  # So python bindins don't install to /usr!

    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--libdir=#{lib}",
                          *exclusions
    ENV.j1
    system "make"
    system "make install"
  end

  def caveats
    s = <<-EOS.undent
    To install Ruby bindings:
      gem install thrift

    To install PHP bindings:
      export PHP_PREFIX=/path/to/homebrew/thrift/0.9.0/php
      export PHP_CONFIG_PREFIX=/path/to/homebrew/thrift/0.9.0/php_extensions
      brew install thrift --with-php

    EOS
    s += python.standard_caveats if python
  end
end
__END__
diff --git a/lib/cpp/src/thrift/transport/TSocket.h b/lib/cpp/src/thrift/transport/TSocket.h
index ff5e541..65e6aea 100644
--- a/lib/cpp/src/thrift/transport/TSocket.h
+++ b/lib/cpp/src/thrift/transport/TSocket.h
@@ -21,6 +21,8 @@
 #define _THRIFT_TRANSPORT_TSOCKET_H_ 1

 #include <string>
+#include <sys/socket.h>
+#include <arpa/inet.h>

 #include "TTransport.h"
 #include "TVirtualTransport.h"
diff --git a/compiler/cpp/src/generate/t_cpp_generator.cc b/compiler/cpp/src/generate/t_cpp_generator.cc
index 6145612..ec4a55f 100644
--- a/compiler/cpp/src/generate/t_cpp_generator.cc
+++ b/compiler/cpp/src/generate/t_cpp_generator.cc
@@ -2503,12 +2503,12 @@ void t_cpp_generator::generate_service_client(t_service* tservice, string style)
       if (!(*f_iter)->is_oneway()) {
         out <<
           indent() << _this << "channel_->sendAndRecvMessage(" <<
-          "std::tr1::bind(cob, this), " << _this << "otrans_.get(), " <<
+          "::apache::thrift::stdcxx::bind(cob, this), " << _this << "otrans_.get(), " <<
           _this << "itrans_.get());" << endl;
       } else {
         out <<
         indent() << _this << "channel_->sendMessage(" <<
-          "std::tr1::bind(cob, this), " << _this << "otrans_.get());" << endl;
+          "::apache::thrift::stdcxx::bind(cob, this), " << _this << "otrans_.get());" << endl;
       }
     }
     scope_down(out);
@@ -2872,8 +2872,8 @@ ProcessorGenerator::ProcessorGenerator(t_cpp_generator* generator,
     class_name_ = service_name_ + pstyle_ + "Processor";
     if_name_ = service_name_ + "CobSvIf";
 
-    finish_cob_ = "std::tr1::function<void(bool ok)> cob, ";
-    finish_cob_decl_ = "std::tr1::function<void(bool ok)>, ";
+    finish_cob_ = "::apache::thrift::stdcxx::function<void(bool ok)> cob, ";
+    finish_cob_decl_ = "::apache::thrift::stdcxx::function<void(bool ok)>, ";
     cob_arg_ = "cob, ";
     ret_type_ = "void ";
   } else {
@@ -3007,25 +3007,25 @@ void ProcessorGenerator::generate_class_definition() {
                         : ", const " + type_name((*f_iter)->get_returntype()) + "& _return");
       f_header_ <<
         indent() << "void return_" << (*f_iter)->get_name() <<
-        "(std::tr1::function<void(bool ok)> cob, int32_t seqid, " <<
+        "(::apache::thrift::stdcxx::function<void(bool ok)> cob, int32_t seqid, " <<
         "::apache::thrift::protocol::TProtocol* oprot, " <<
         "void* ctx" << ret_arg << ");" << endl;
       if (generator_->gen_templates_) {
         f_header_ <<
           indent() << "void return_" << (*f_iter)->get_name() <<
-          "(std::tr1::function<void(bool ok)> cob, int32_t seqid, " <<
+          "(::apache::thrift::stdcxx::function<void(bool ok)> cob, int32_t seqid, " <<
           "Protocol_* oprot, void* ctx" << ret_arg << ");" << endl;
       }
       // XXX Don't declare throw if it doesn't exist
       f_header_ <<
         indent() << "void throw_" << (*f_iter)->get_name() <<
-        "(std::tr1::function<void(bool ok)> cob, int32_t seqid, " <<
+        "(::apache::thrift::stdcxx::function<void(bool ok)> cob, int32_t seqid, " <<
         "::apache::thrift::protocol::TProtocol* oprot, void* ctx, " <<
         "::apache::thrift::TDelayedException* _throw);" << endl;
       if (generator_->gen_templates_) {
         f_header_ <<
           indent() << "void throw_" << (*f_iter)->get_name() <<
-          "(std::tr1::function<void(bool ok)> cob, int32_t seqid, " <<
+          "(::apache::thrift::stdcxx::function<void(bool ok)> cob, int32_t seqid, " <<
           "Protocol_* oprot, void* ctx, " <<
           "::apache::thrift::TDelayedException* _throw);" << endl;
       }
@@ -3951,7 +3951,7 @@ void t_cpp_generator::generate_process_function(t_service* tservice,
     out <<
       "void " << tservice->get_name() << "AsyncProcessor" << class_suffix <<
       "::process_" << tfunction->get_name() <<
-      "(std::tr1::function<void(bool ok)> cob, int32_t seqid, " <<
+      "(::apache::thrift::stdcxx::function<void(bool ok)> cob, int32_t seqid, " <<
       prot_type << "* iprot, " << prot_type << "* oprot)" << endl;
     scope_up(out);
 
@@ -4009,7 +4009,7 @@ void t_cpp_generator::generate_process_function(t_service* tservice,
 
     // TODO(dreiss): Handle TExceptions?  Expose to server?
     out <<
-      indent() << "catch (const std::exception& exn) {" << endl <<
+      indent() << "catch (const std::exception&) {" << endl <<
       indent() << "  if (this->eventHandler_.get() != NULL) {" << endl <<
       indent() << "    this->eventHandler_->handlerError(ctx, " <<
         service_func_name << ");" << endl <<
@@ -4032,14 +4032,14 @@ void t_cpp_generator::generate_process_function(t_service* tservice,
       // TODO(dreiss): Call the cob immediately?
       out <<
         indent() << "iface_->" << tfunction->get_name() << "(" <<
-        "std::tr1::bind(cob, true)" << endl;
+        "::apache::thrift::stdcxx::bind(cob, true)" << endl;
       indent_up(); indent_up();
     } else {
       string ret_arg, ret_placeholder;
       if (!tfunction->get_returntype()->is_void()) {
         ret_arg = ", const " + type_name(tfunction->get_returntype()) +
           "& _return";
-        ret_placeholder = ", std::tr1::placeholders::_1";
+        ret_placeholder = ", ::apache::thrift::stdcxx::placeholders::_1";
       }
 
       // When gen_templates_ is true, the return_ and throw_ functions are
@@ -4047,7 +4047,7 @@ void t_cpp_generator::generate_process_function(t_service* tservice,
       // can resolve the correct overloaded version.
       out <<
         indent() << "void (" << tservice->get_name() << "AsyncProcessor" <<
-        class_suffix << "::*return_fn)(std::tr1::function<void(bool ok)> " <<
+        class_suffix << "::*return_fn)(::apache::thrift::stdcxx::function<void(bool ok)> " <<
         "cob, int32_t seqid, " << prot_type << "* oprot, void* ctx" <<
         ret_arg << ") =" << endl;
       out <<
@@ -4056,7 +4056,7 @@ void t_cpp_generator::generate_process_function(t_service* tservice,
       if (!xceptions.empty()) {
         out <<
           indent() << "void (" << tservice->get_name() << "AsyncProcessor" <<
-          class_suffix << "::*throw_fn)(std::tr1::function<void(bool ok)> " <<
+          class_suffix << "::*throw_fn)(::apache::thrift::stdcxx::function<void(bool ok)> " <<
           "cob, int32_t seqid, " << prot_type << "* oprot, void* ctx, " <<
           "::apache::thrift::TDelayedException* _throw) =" << endl;
         out <<
@@ -4068,13 +4068,13 @@ void t_cpp_generator::generate_process_function(t_service* tservice,
         indent() << "iface_->" << tfunction->get_name() << "(" << endl;
       indent_up(); indent_up();
       out <<
-        indent() << "std::tr1::bind(return_fn, this, cob, seqid, oprot, ctx" <<
+        indent() << "::apache::thrift::stdcxx::bind(return_fn, this, cob, seqid, oprot, ctx" <<
         ret_placeholder << ")";
       if (!xceptions.empty()) {
         out
           << ',' << endl <<
-          indent() << "std::tr1::bind(throw_fn, this, cob, seqid, oprot, " <<
-          "ctx, std::tr1::placeholders::_1)";
+          indent() << "::apache::thrift::stdcxx::bind(throw_fn, this, cob, seqid, oprot, " <<
+          "ctx, ::apache::thrift::stdcxx::placeholders::_1)";
       }
     }
 
@@ -4104,7 +4104,7 @@ void t_cpp_generator::generate_process_function(t_service* tservice,
       out <<
         "void " << tservice->get_name() << "AsyncProcessor" << class_suffix <<
         "::return_" << tfunction->get_name() <<
-        "(std::tr1::function<void(bool ok)> cob, int32_t seqid, " <<
+        "(::apache::thrift::stdcxx::function<void(bool ok)> cob, int32_t seqid, " <<
         prot_type << "* oprot, void* ctx" << ret_arg_decl << ')' << endl;
       scope_up(out);
 
@@ -4173,7 +4173,7 @@ void t_cpp_generator::generate_process_function(t_service* tservice,
       out <<
         "void " << tservice->get_name() << "AsyncProcessor" << class_suffix <<
         "::throw_" << tfunction->get_name() <<
-        "(std::tr1::function<void(bool ok)> cob, int32_t seqid, " <<
+        "(::apache::thrift::stdcxx::function<void(bool ok)> cob, int32_t seqid, " <<
         prot_type << "* oprot, void* ctx, " <<
         "::apache::thrift::TDelayedException* _throw)" << endl;
       scope_up(out);
@@ -5037,7 +5037,7 @@ string t_cpp_generator::function_signature(t_function* tfunction,
                   ? "()"
                   : ("(" + type_name(ttype) + " const& _return)"));
       if (has_xceptions) {
-        exn_cob = ", std::tr1::function<void(::apache::thrift::TDelayedException* _throw)> /* exn_cob */";
+        exn_cob = ", ::apache::thrift::stdcxx::function<void(::apache::thrift::TDelayedException* _throw)> /* exn_cob */";
       }
     } else {
       throw "UNKNOWN STYLE";
@@ -5045,7 +5045,7 @@ string t_cpp_generator::function_signature(t_function* tfunction,
 
     return
       "void " + prefix + tfunction->get_name() +
-      "(std::tr1::function<void" + cob_type + "> cob" + exn_cob +
+      "(::apache::thrift::stdcxx::function<void" + cob_type + "> cob" + exn_cob +
       argument_list(arglist, name_params, true) + ")";
   } else {
     throw "UNKNOWN STYLE";
