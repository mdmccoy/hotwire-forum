// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import "bootstrap"
import "bootstrap/dist/css/bootstrap.min.css"

Turbo.StreamActions.redirect = function () {
  Turbo.visit(this.target);
};
import "trix"
import "@rails/actiontext"
