defmodule Fulcrum.Initializer.Inviter do
  use Mailgun.Client, domain: Application.get_env(:addict, :mailgun_domain),
                      key: Application.get_env(:addict, :mailgun_key)
  def run() do
    SecureRandom.hex(60)
    |> send_nonce_email
  end

  defp send_nonce_email(nonce) do
    send_email(to: Fulcrum.Settings.owner_email,
      from: Application.get_env(:addict, :register_from_email),
      subject: "Fulcrum is ready for you!",
      html: html_body(nonce),
      text: text_body(nonce))
    nonce
  end

  defp html_body(nonce) do
    """
    <h4>Hello from your new Fulcrum instance!</h4>
    <br />
    <p>
    It's ready for you, <a href="#{token_validation_url(nonce)}">click here</a> to get in!.
    </p>
    
    <small><p> or copy pasta this link: #{token_validation_url(nonce)} </p></small>

    <p> 💘, </p>
    <p> Jake </p>
    """
  end

  defp text_body(nonce) do
    """
    Hello from your new Fulcrum instance!

    It's ready for you, but you need this number to get in: #{nonce}

    or copy pasta this link:

    #{token_validation_url(nonce)}
    """
  end

  defp token_validation_url(nonce) do
    "https://#{Fulcrum.Settings.top_domain}/setup/validate_token?token=#{nonce}"
  end
end
